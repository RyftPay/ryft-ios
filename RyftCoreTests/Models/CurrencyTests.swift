import XCTest

@testable import RyftCore

class CurrencyTests: XCTestCase {

    func test_fromCode_shouldReturnExpectedCurrencyForGBP() {
        XCTAssertEqual(Currency.from(code: "GBP"), Currency(code: "GBP", minorUnits: 2))
    }

    func test_fromCode_shouldReturnExpectedCurrencyForEUR() {
        XCTAssertEqual(Currency.from(code: "EUR"), Currency(code: "EUR", minorUnits: 2))
    }

    func test_dividor_shouldReturnExpectedValue_forGBP() {
        XCTAssertEqual(Currency.from(code: "GBP").dividor(), 100)
    }

    func test_dividor_shouldReturnExpectedValue_forEUR() {
        XCTAssertEqual(Currency.from(code: "EUR").dividor(), 100)
    }

    func test_equatable_shouldReturnFalse_whenDigitsDiffer() {
        let first = Currency(code: "GBP", minorUnits: 2)
        let second = Currency(code: "GBP", minorUnits: 4)
        XCTAssertNotEqual(first, second)
    }

    func test_equatable_shouldReturnFalse_whenCodeDiffers() {
        let first = Currency(code: "GBP", minorUnits: 2)
        let second = Currency(code: "EUR", minorUnits: 2)
        XCTAssertNotEqual(first, second)
    }

    func test_equatable_shouldReturnTrue_whenNoFieldsDiffer() {
        let first = Currency(code: "GBP", minorUnits: 2)
        let second = Currency(code: "GBP", minorUnits: 2)
        XCTAssertEqual(first, second)
    }
}
