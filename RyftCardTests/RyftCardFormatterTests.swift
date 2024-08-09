import XCTest

@testable import RyftCard

final class RyftCardFormatterTests: XCTestCase {

    func test_sanitisedExpiration_shouldReturnEmptyPair_whenValueIsEmpty() {
        let result = RyftCardFormatter.sanitisedExpiration(expiration: "")
        XCTAssertEqual("", result.month)
        XCTAssertEqual("", result.year)
    }

    func test_sanitisedExpiration_shouldReturnEmptyMonth_whenValueIsNonNumerical() {
        let result = RyftCardFormatter.sanitisedExpiration(expiration: "hello")
        XCTAssertEqual("", result.month)
        XCTAssertEqual("", result.year)
    }

    func test_sanitisedExpiration_shouldReturnExpectedMonth_whenValueIsZero() {
        let result = RyftCardFormatter.sanitisedExpiration(expiration: "0")
        XCTAssertEqual("0", result.month)
        XCTAssertEqual("", result.year)
    }

    func test_sanitisedExpiration_shouldReturnExpectedPair_whenValueOnlyDoubleDigits() {
        let result = RyftCardFormatter.sanitisedExpiration(expiration: "10")
        XCTAssertEqual("10", result.month)
        XCTAssertEqual("", result.year)
    }

    func test_sanitisedExpiration_shouldReturnExpectedPair_whenValueIsThreeDigits() {
        let result = RyftCardFormatter.sanitisedExpiration(expiration: "03/1")
        XCTAssertEqual("03", result.month)
        XCTAssertEqual("1", result.year)
    }

    func test_sanitisedExpiration_shouldReturnExpectedPair_whenValueIsFourDigits() {
        let result = RyftCardFormatter.sanitisedExpiration(expiration: "03/24")
        XCTAssertEqual("03", result.month)
        XCTAssertEqual("24", result.year)
    }

    func test_sanitisedExpiration_shouldReturnExpectedPair_whenValueIsFiveDigits() {
        let result = RyftCardFormatter.sanitisedExpiration(expiration: "03/204")
        XCTAssertEqual("03", result.month)
        XCTAssertEqual("204", result.year)
    }

    func test_sanitisedName_ShouldReturnExpectedValue() {
        let testCases = [
            ["MR CAL KESTIS", "MR CAL KESTIS"],
            [" MR CAL KESTIS", "MR CAL KESTIS"],
            ["MR CAL KESTIS ", "MR CAL KESTIS"],
            [" MR CAL KESTIS ", "MR CAL KESTIS"],
            ["  MR CAL KESTIS  ", "MR CAL KESTIS"],
            [" CAL KESTIS", "CAL KESTIS"]
        ]
        testCases.forEach {
            XCTAssertEqual(
                $0[1],
                RyftCardFormatter.sanitisedName(value: $0[0])
            )
        }
    }

    func test_formatVisaCardNumbers_shouldReturnExpectedValue() {
        let testCases = [
            ["4242424242424242", "4242 4242 4242 4242"],
            ["4111111111111111", "4111 1111 1111 1111"],
            ["4012888888881881", "4012 8888 8888 1881"]
        ]
        testCases.forEach {
            XCTAssertEqual(
                $0[1],
                RyftCardFormatter.format(cardNumber: $0[0], with: .visa)
            )
        }
    }

    func test_formatMastercardCardNumbers_shouldReturnExpectedValue() {
        let testCases = [
            ["5301530153015301", "5301 5301 5301 5301"],
            ["5105105105105100", "5105 1051 0510 5100"],
            ["5555555555554444", "5555 5555 5555 4444"]
        ]
        testCases.forEach {
            XCTAssertEqual(
                $0[1],
                RyftCardFormatter.format(cardNumber: $0[0], with: .mastercard)
            )
        }
    }

    func test_formatAmexCardNumbers_shouldReturnExpectedValue() {
        let testCases = [
            ["378282246310005", "3782 822463 10005"],
            ["371449635398431", "3714 496353 98431"],
            ["378734493671000", "3787 344936 71000"]
        ]
        testCases.forEach {
            XCTAssertEqual(
                $0[1],
                RyftCardFormatter.format(cardNumber: $0[0], with: .amex)
            )
        }
    }
}
