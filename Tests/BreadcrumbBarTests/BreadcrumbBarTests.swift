import XCTest
@testable import BreadcrumbBar

final class BreadcrumbBarTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BreadcrumbBar().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
