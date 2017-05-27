import XCTest
@testable import DoctorPrettyTests

XCTMain([
    testCase(DoctorPrettyTests.allTests),
    testCase(DocSpecs.allTests)
])
