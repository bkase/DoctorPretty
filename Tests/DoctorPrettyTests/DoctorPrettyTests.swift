import XCTest
@testable import DoctorPretty
import Operadics

class DoctorPrettyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let words = "some text to lay out".components(separatedBy: " ").map{ Doc.text($0) }
            
        let doc = Doc.text("some") <+> Doc.sep(words)
        
        print(doc.renderPretty(ribbonFrac: 0.5, pageWidth: 5).displayString())
        XCTAssert(false)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
