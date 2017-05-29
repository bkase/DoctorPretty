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
            doc: words.fillSep().hang(4)
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

    func testPunctuate() {
        assertPretty(
            pageWidth: 80,
            str: "a,b,c",
            doc: ["a", "b", "c"]
                .map(Doc.char)
                .punctuate(with: Doc.comma)
                .cat()
        )
    }

    func testEncloseSep() {
        let list1 = ["foo", "bar", "baz"]
                .map(Doc.text)
                .list(indent: 4)
        let doc = .text("let x =") <%> list1

        assertPretty(
            pageWidth: 80,
            str: "let x = [foo, bar, baz]",
            doc: doc
        )

        assertPretty(
            pageWidth: 10,
            str: ["let x = [",
	            "    foo,",
	            "    bar,",
	            "    baz",
            "]"].joined(separator: "\n"),
            doc: doc
        )

        let list2 = [list1].list(indent: 4)
        let list3 = [list2].list(indent: 4)
        let docBigger = .text("let x =") <%> list3

        assertPretty(
            pageWidth: 20,
            str: ["let x = [",
                "    [",
                "        [",
	            "            foo,",
	            "            bar,",
	            "            baz",
                "        ]",
                "    ]",
            "]"].joined(separator: "\n"),
            doc: docBigger
        )
    }

    func testSwiftExample() {
        let Indentation = 4
        let funName: Doc = .text("aLongFunction")
        let args: Doc = [
            ("foo", "String"),
            ("bar", "Int"),
            ("baz", "Long")
        ].map{ (name, typ) in
	        .text(name) <> .text(":") <%> .text(typ)
        }.tupled(indent: Indentation)
        let retType: Doc = ["String", "Int", "Long"]
            .map(Doc.text)
            .tupled(indent: Indentation)
        let retValue: Doc = ["foo", "bar", "baz"]
            .map(Doc.text)
            .tupled(indent: Indentation)
        let retExpr: Doc = .text("return") <%> retValue
        let body: Doc = [
		          .text("sideEffect()"),
		          retExpr
            ].vsep()
        let funcBody: Doc = [
            Doc.lbrace, body.indent(Indentation), Doc.rbrace
        ].vsep()
        let doc: Doc =
            .text("func") <> Doc.space <> funName <> args <> Doc.space <> .text("->") <> Doc.space <> retType <%> funcBody

        assertPretty(pageWidth: 120, str: [
"func aLongFunction(foo: String, bar: Int, baz: Long) -> (String, Int, Long) {",
"    sideEffect()",
"    return (foo, bar, baz)",
"}"
            ].joined(separator: "\n"), doc: doc)

        assertPretty(pageWidth: 40, str: [
"func aLongFunction(",
"    foo: String, bar: Int, baz: Long",
") -> (String, Int, Long) {",
"    sideEffect()",
"    return (foo, bar, baz)",
"}"
            ].joined(separator: "\n"), doc: doc)

        assertPretty(pageWidth: 20, str: [
"func aLongFunction(",
"    foo: String,",
"    bar: Int,",
"    baz: Long",
") -> (",
"    String,",
"    Int,",
"    Long",
") {",
"    sideEffect()",
"    return (",
"        foo,",
"        bar,",
"        baz",
"    )",
"}"
            ].joined(separator: "\n"), doc: doc)
    }

    static var allTests = [
        ("testSimpleConstructors", testSimpleConstructors),
        ("testFlatAltConstructor", testFlatAltConstructor),
        ("testCat", testCat),
        ("testNest", testNest),
        ("testUnion", testUnion),
        ("testFuncConstructors", testFuncConstructors),
        ("testHang", testHang),
        ("testAlign", testAlign),
        ("testPunctuate", testPunctuate),
        ("testEncloseSep", testEncloseSep),
        ("testSwiftExample", testSwiftExample)
    ]
}
