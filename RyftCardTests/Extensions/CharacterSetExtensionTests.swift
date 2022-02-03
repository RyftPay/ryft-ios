import XCTest

@testable import RyftCard

final class CharacterSetExtensionTests: XCTestCase {

    func test_numeric_shouldReturnExpectedSet() {
        XCTAssertEqual(CharacterSet(charactersIn: "0123456789"), CharacterSet.numeric)
    }

    func test_nonNumeric_shouldReturnExpectedSet() {
        XCTAssertEqual(CharacterSet(charactersIn: "0123456789").inverted, CharacterSet.nonNumeric)
    }
}
