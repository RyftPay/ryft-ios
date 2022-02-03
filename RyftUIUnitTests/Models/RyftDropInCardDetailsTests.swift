import XCTest

@testable import RyftUI
@testable import RyftCard

final class RyftDropInCardDetailsTest: XCTestCase {

    func test_incomplete_shouldReturnExpectedValue() {
        let cardDetails = RyftDropInCardDetails.incomplete
        let expected = RyftDropInCardDetails(
            cardNumber: "",
            expirationMonth: "",
            expirationYear: "",
            cvc: "",
            cardNumberState: .incomplete,
            expirationState: .incomplete,
            cvcState: .incomplete
        )
        XCTAssertEqual(expected, cardDetails)
    }

    func test_isValid_shouldReturnFalse_forIncompleteCardDetails() {
        let cardDetails = RyftDropInCardDetails.incomplete
        XCTAssertFalse(cardDetails.isValid())
    }

    func test_isValid_shouldReturnFalse_whenCardNumberIsInvalid() {
        let cardDetails = cardWithStates(cardNumberState: .invalid)
        XCTAssertFalse(cardDetails.isValid())
    }

    func test_isValid_shouldReturnFalse_whenExpirationIsInvalid() {
        let cardDetails = cardWithStates(expirationState: .invalid)
        XCTAssertFalse(cardDetails.isValid())
    }

    func test_isValid_shouldReturnFalse_whenCvcIsInvalid() {
        let cardDetails = cardWithStates(cvcState: .invalid)
        XCTAssertFalse(cardDetails.isValid())
    }

    func test_isValid_shouldReturnTrue_whenAllStatesAreValid() {
        let cardDetails = cardWithStates(
            cardNumberState: .valid,
            expirationState: .valid,
            cvcState: .valid
        )
        XCTAssertTrue(cardDetails.isValid())
    }

    func test_withCardNumber_shouldReturnExpectedUpdatedValue() {
        let cardDetails = RyftDropInCardDetails.incomplete
            .with(cardNumber: "4242424242424242", and: .valid)
        let expected = RyftDropInCardDetails(
            cardNumber: "4242424242424242",
            expirationMonth: "",
            expirationYear: "",
            cvc: "",
            cardNumberState: .valid,
            expirationState: .incomplete,
            cvcState: .incomplete
        )
        XCTAssertEqual(expected, cardDetails)
    }

    func test_withExpiration_shouldReturnExpectedUpdatedValue() {
        let cardDetails = RyftDropInCardDetails.incomplete
            .with(expirationMonth: "10", expirationYear: "24", and: .valid)
        let expected = RyftDropInCardDetails(
            cardNumber: "",
            expirationMonth: "10",
            expirationYear: "2024",
            cvc: "",
            cardNumberState: .incomplete,
            expirationState: .valid,
            cvcState: .incomplete
        )
        XCTAssertEqual(expected, cardDetails)
    }

    func test_withCvc_shouldReturnExpectedUpdatedValue() {
        let cardDetails = RyftDropInCardDetails.incomplete
            .with(cvc: "100", and: .valid)
        let expected = RyftDropInCardDetails(
            cardNumber: "",
            expirationMonth: "",
            expirationYear: "",
            cvc: "100",
            cardNumberState: .incomplete,
            expirationState: .incomplete,
            cvcState: .valid
        )
        XCTAssertEqual(expected, cardDetails)
    }

    private func cardWithStates(
        cardNumberState: RyftInputValidationState = .incomplete,
        expirationState: RyftInputValidationState = .incomplete,
        cvcState: RyftInputValidationState = .incomplete
    ) -> RyftDropInCardDetails {
        return RyftDropInCardDetails(
            cardNumber: "",
            expirationMonth: "",
            expirationYear: "",
            cvc: "",
            cardNumberState: cardNumberState,
            expirationState: expirationState,
            cvcState: cvcState
        )
    }
}
