import XCTest
@testable import DoctorPretty
import Operadics

// Most tests ported from https://github.com/minad/wl-pprint-annotated/blob/master/test/WLPPrintTests.hs
class DoctorPrettyTests: XCTestCase {
    func assertPretty(pageWidth: Width, str: String, doc: Doc) {
        XCTAssertEqual(doc.renderPretty(ribbonFrac: 1.0, pageWidth: pageWidth).displayString(), str)
    }
    
    func testSimpleConstructors() {
        assertPretty(pageWidth: 80, str: "", doc: Doc.zero)
        assertPretty(pageWidth: 80, str: "a", doc: Doc.char("a"))
        assertPretty(pageWidth: 80, str: "text...", doc: Doc.text("text..."))
        assertPretty(pageWidth: 80, str: "\n", doc: Doc.hardline)
    }
    
    func testFlatAltConstructor() {
        assertPretty(pageWidth: 80, str: "x", doc: .flatAlt(primary: .text("x"), whenFlattened: .text("y")))
        assertPretty(pageWidth: 80, str: "y", doc: Doc.flatAlt(primary: .text("x"), whenFlattened: .text("y")).flattened)
    }
    
    func testCat() {
        assertPretty(pageWidth: 80, str: "some code", doc: .text("some") <> Doc.space <> .text("code"))
    }
    
    func testNest() {
        assertPretty(
            pageWidth: 80,
            str: "foo bar",
            doc: .text("foo") <+> .nest(2, .text("bar"))
        )
        
        assertPretty(
            pageWidth: 80,
            str: "foo\n  bar",
            doc: .text("foo") <> .nest(2, .line <> .text("bar"))
        )
    }
    
    func testUnion() {
        assertPretty(pageWidth: 80, str: "foo bar",
                     doc: .text("foo") <%> .text("bar"))
        assertPretty(pageWidth: 5, str: "foo\nbar",
                     doc: .text("foo") <%> .text("bar"))
    }
    
    func testFuncConstructors() {
        assertPretty(pageWidth: 80, str: "foo 4",
                     doc: .text("foo") <+> .column { .text("\($0)") })
        assertPretty(pageWidth: 80, str: "foo 2",
                     doc: .text("foo") <+> .nest(2, .nesting { .text("\($0)") }))
        assertPretty(pageWidth: 21, str: "foo 21",
                     doc: .text("foo") <+> .nest(2, .columns { .text("\($0!)") }))
        XCTAssertEqual("foo 40",
                       (.text("foo") <+> .ribbon { .text("\($0!)") }).renderPrettyDefault().displayString())
    }
    
    func testHang() {
        let words = "the hang combinator indents these words !".components(separatedBy: " ").map{ Doc.text($0) }
        
        assertPretty(
            pageWidth: 20,
            str: ["the hang combinator",
                  "    indents these",
                  "    words !" ].joined(separator: "\n"),
            doc: Doc.fillSep(words).hang(4)
        )
    }
    
    func testAlign() {
        assertPretty(
            pageWidth: 20,
            str: ["hi nice",
                  "   world" ].joined(separator: "\n"),
            doc: .text("hi") <+> ((.text("nice") <> .linebreak <> .text("world"))).align()
        )
    }
    
    // WIP
    /*func testSwiftExample() {
        func fun(name: String, args: [(String, Doc)]) -> Doc {
            let funHead = .text(name) <> Doc.lparen
            let args = args.map{ (name, doc) in
                (.text(name) <> .text(":")) <%> doc
            }
        }
        assertPretty(pageWidth: 80, str: "", doc: Doc.zero)

    }*/

    static var allTests = [
        ("testSimpleConstructors", testSimpleConstructors),
        ("testFlatAltConstructor", testFlatAltConstructor),
        ("testCat", testCat),
        ("testNest", testNest),
        ("testUnion", testUnion),
        ("testFuncConstructors", testFuncConstructors),
        ("testHang", testHang),
        ("testAlign", testAlign)
    ]
}
