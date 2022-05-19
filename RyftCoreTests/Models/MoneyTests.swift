import XCTest

@testable import RyftCore

class MoneyTests: XCTestCase {

    func test_fromAmountAndCode_shouldReturnExpectedValue() {
        let expected = Money(currency: Currency.from(code: "GBP"), amount: 1000)
        XCTAssertEqual(Money.from(1000, currencyCode: "GBP"), expected)
    }

    func test_fromEuroCode_shouldReturnExpectedValue() {
        let expected = Money(currency: Currency.from(code: "EUR"), amount: 2000)
        XCTAssertEqual(Money.from(2000, currencyCode: "EUR"), expected)
    }

    func test_fromUsdCode_ShouldReturnExpectedValue() {
        let expected = Money(currency: Currency.from(code: "USD"), amount: 2000)
        XCTAssertEqual(Money.from(2000, currencyCode: "USD"), expected)
    }

    func test_fromCadCode_ShouldReturnExpectedValue() {
        let expected = Money(currency: Currency.from(code: "CAD"), amount: 2000)
        XCTAssertEqual(Money.from(2000, currencyCode: "CAD"), expected)
    }

    func test_equatable_shouldReturnFalse_whenCurrencyDiffers() {
        let first = Money.from(1000, currencyCode: "GBP")
        let second = Money.from(1000, currencyCode: "EUR")
        XCTAssertNotEqual(first, second)
    }

    func test_equatable_shouldReturnFalse_whenAmountDiffers() {
        let first = Money.from(1000, currencyCode: "GBP")
        let second = Money.from(1500, currencyCode: "GBP")
        XCTAssertNotEqual(first, second)
    }

    func test_equatable_shouldReturnTrue_whenCurrencyAndAmountMatch() {
        let first = Money(currencyCode: "EUR", amount: 5000)
        let second = Money(currencyCode: "EUR", amount: 5000)
        XCTAssertEqual(first, second)
    }

    func test_calculatePercentageAmount_shouldReturnExpectedValue_forWholeAmount() {
        let initial = Money(currencyCode: "GBP", amount: 200)
        let expected = Money(currencyCode: "GBP", amount: 120)
        XCTAssertEqual(initial.calculatePercentageAmount(with: 60), expected)
    }

    func test_calculatePercentageAmount_shouldReturnExpectedValue_forRoundedAmount() {
        let initial = Money(currencyCode: "GBP", amount: 45)
        let expected = Money(currencyCode: "GBP", amount: 4)
        XCTAssertEqual(initial.calculatePercentageAmount(with: 10), expected)
    }

    func test_subtractOperator_shouldReturnExpectedResult() {
        let left = Money(currencyCode: "GBP", amount: 4500)
        let right = Money(currencyCode: "GBP", amount: 1250)
        let expected = Money(currencyCode: "GBP", amount: 3250)
        XCTAssertEqual((left - right), expected)
    }

    func test_amountInMajorUnits_shouldReturnExpectedResultForGBP() {
        let money = Money(currencyCode: "GBP", amount: 2576)
        let expected = NSDecimalNumber(25.76)
        XCTAssertEqual(money.amountInMajorUnits(), expected)
    }

    func test_amountInMajorUnits_shouldReturnExpectedResultForEUR() {
        let money = Money(currencyCode: "EUR", amount: 3456)
        let expected = NSDecimalNumber(34.56)
        XCTAssertEqual(money.amountInMajorUnits(), expected)
    }

    func test_amountInMajorUnits_shouldReturnExpectedValueForUsd() {
        let money = Money(currencyCode: "USD", amount: 5678)
        let expected = NSDecimalNumber(56.78)
        XCTAssertEqual(money.amountInMajorUnits(), expected)
    }

    func test_amountInMajorUnits_shouldReturnExpectedValueForCad() {
        let money = Money(currencyCode: "CAD", amount: 3256)
        let expected = NSDecimalNumber(32.56)
        XCTAssertEqual(money.amountInMajorUnits(), expected)
    }

    func test_gt_shouldReturnFalseWhenExpected() {
        let left = Money(currencyCode: "GBP", amount: 4500)
        let right = Money(currencyCode: "GBP", amount: 4500)
        XCTAssertFalse(left > right)
    }

    func test_gt_shouldReturnTrueWhenExpected() {
        let left = Money(currencyCode: "GBP", amount: 4501)
        let right = Money(currencyCode: "GBP", amount: 4500)
        XCTAssertTrue(left > right)
    }

    func test_gt_withIntType_shouldReturnFalseWhenExpected() {
        let left = Money(currencyCode: "GBP", amount: 4500)
        XCTAssertFalse(left > 4500)
    }

    func test_gt_withIntType_shouldReturnTrueWhenExpected() {
        let left = Money(currencyCode: "GBP", amount: 4501)
        XCTAssertTrue(left > 4500)
    }

    func test_lt_shouldReturnFalseWhenExpected() {
        let left = Money(currencyCode: "GBP", amount: 4500)
        let right = Money(currencyCode: "GBP", amount: 4500)
        XCTAssertFalse(left < right)
    }

    func test_lt_shouldReturnTrueWhenExpected() {
        let left = Money(currencyCode: "GBP", amount: 4499)
        let right = Money(currencyCode: "GBP", amount: 4500)
        XCTAssertTrue(left < right)
    }

    func test_plusOperatorWithIntType_shouldCorrectlyAdd() {
        let left = Money(currencyCode: "GBP", amount: 400)
        let expected = Money(currencyCode: "GBP", amount: 900)
        XCTAssertEqual(expected, left + 500)
    }

    func test_plusOperatorWithSameType_shouldCorrectlyAdd() {
        let left = Money(currencyCode: "GBP", amount: 450)
        let right = Money(currencyCode: "GBP", amount: 250)
        let expected = Money(currencyCode: "GBP", amount: 700)
        XCTAssertEqual(expected, left + right)
    }

    func test_plusOperatorwithNil_shouldAddZero() {
        let left = Money(currencyCode: "GBP", amount: 450)
        XCTAssertEqual(left, left + nil)
    }

    func test_multiplyOperatorWithLeftHandSide_shouldReturnExpectedResult() {
        let left = Money(currencyCode: "GBP", amount: 450)
        let expected = Money(currencyCode: "GBP", amount: 2250)
        XCTAssertEqual(expected, 5 * left)
    }

    func test_multiplyOperatorWithRightHandSide_shouldReturnExpectedResult() {
        let left = Money(currencyCode: "GBP", amount: 450)
        let expected = Money(currencyCode: "GBP", amount: 2250)
        XCTAssertEqual(expected, left * 5)
    }
}
