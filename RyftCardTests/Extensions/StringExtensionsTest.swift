import XCTest

@testable import RyftCard

final class StringExtensionsTest: XCTestCase {

    func test_isNumeric_shouldReturnFalse_forValueContainingLetters() {
        XCTAssertFalse("abc123".isNumeric())
    }

    func test_isNumeric_shouldReturnFalse_forValueWithWhitespace() {
        XCTAssertFalse(" 12".isNumeric())
    }

    func test_isNumeric_shouldReturnTrue_forNumberValue() {
        XCTAssertTrue("0123".isNumeric())
    }

    func test_isNonNumeric_shouldReturnTrue_forValueContainingLetters() {
        XCTAssertTrue("abc123".isNonNumeric())
    }

    func test_isNonNumeric_shouldReturnTrue_forValueWithWhitespace() {
        XCTAssertTrue(" 12".isNonNumeric())
    }

    func test_isNonNumeric_shouldReturnFalse_forNumberValue() {
        XCTAssertFalse("0123".isNonNumeric())
    }

    func test_numericsOnly_shouldReturnValueWithNonDigitsRemoved() {
        let testCases = [
            ["abc12", "12"],
            ["  12a3", "123"],
            ["abc", ""]
        ]
        testCases.forEach {
            XCTAssertEqual($0[1], $0[0].numericsOnly())
        }
    }

    func test_numberOfWords_shouldReturnExpectedValue() {
        let testCases: [(String, Int)] = [
            ("", 0),
            (" ", 0),
            ("   ", 0),
            ("one", 1),
            (" one", 1),
            (" one  ", 1),
            ("one two", 2),
            ("one two  three", 3)
        ]
        testCases.forEach {
            XCTAssertEqual($0.1, $0.0.numberOfWords())
        }
    }
}
