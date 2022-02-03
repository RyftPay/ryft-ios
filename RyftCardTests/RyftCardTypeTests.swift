import XCTest
@testable import RyftCard

final class RyftCardTypeTests: XCTestCase {

    func test_visa_shouldHaveExpectedShape() {
        let expected = RyftCardType(
            scheme: .visa,
            displayName: "Visa",
            cardLengths: [13, 16],
            cvcLength: 3,
            cardNumberFormatGaps: [4, 8, 12],
            binRanges: [CardBinRange(min: 4, max: 4)]
        )
        XCTAssertEqual(expected, RyftCardType.visa)
    }

    func test_mastercard_shouldHaveExpectedShape() {
        let expected = RyftCardType(
            scheme: .mastercard,
            displayName: "Mastercard",
            cardLengths: [16],
            cvcLength: 3,
            cardNumberFormatGaps: [4, 8, 12],
            binRanges: [
                CardBinRange(min: 2221, max: 2720),
                CardBinRange(min: 51, max: 55)
            ]
        )
        XCTAssertEqual(expected, .mastercard)
    }

    func test_amex_shouldHaveExpectedShape() {
        let expected = RyftCardType(
            scheme: .amex,
            displayName: "American Express",
            cardLengths: [15],
            cvcLength: 4,
            cardNumberFormatGaps: [4, 10],
            binRanges: [
                CardBinRange(min: 34, max: 34),
                CardBinRange(min: 37, max: 37)
            ]
        )
        XCTAssertEqual(expected, .amex)
    }

    func test_unknown_shouldHaveExpectedShape() {
        let expected = RyftCardType(
            scheme: .unknown,
            displayName: "Unknown",
            cardLengths: [24],
            cvcLength: 4,
            cardNumberFormatGaps: [],
            binRanges: []
        )
        XCTAssertEqual(expected, .unknown)
    }

    func test_cardTypes_shouldLookupCorrectValueForVisa() {
        XCTAssertEqual(RyftCardType.visa, .visa)
    }

    func test_cardTypes_shouldLookupCorrectValueForMastercard() {
        XCTAssertEqual(RyftCardType.mastercard, .mastercard)
    }

    func test_cardTypes_shouldLookupCorrectValueForAmex() {
        XCTAssertEqual(RyftCardType.amex, .amex)
    }

    func test_cardTypes_shouldLookupCorrectValueForUnknown() {
        XCTAssertEqual(RyftCardType.unknown, .unknown)
    }
}
