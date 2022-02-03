import RyftCard

struct RyftDropInCardDetails: Equatable, Hashable {

     let cardNumber: String
     let expirationMonth: String
     let expirationYear: String
     let cvc: String
     let cardNumberState: RyftInputValidationState
     let expirationState: RyftInputValidationState
     let cvcState: RyftInputValidationState

     func isValid() -> Bool {
        return [cardNumberState, expirationState, cvcState].allSatisfy { $0 == .valid }
    }

     func with(
        cardNumber: String,
        and state: RyftInputValidationState
    ) -> RyftDropInCardDetails {
        return RyftDropInCardDetails(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            cvc: cvc,
            cardNumberState: state,
            expirationState: expirationState,
            cvcState: cvcState
        )
    }

     func with(
        expirationMonth: String,
        expirationYear: String,
        and state: RyftInputValidationState
    ) -> RyftDropInCardDetails {
        return RyftDropInCardDetails(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: "20\(expirationYear)",
            cvc: cvc,
            cardNumberState: cardNumberState,
            expirationState: state,
            cvcState: cvcState
        )
    }

     func with(
        cvc: String,
        and state: RyftInputValidationState
    ) -> RyftDropInCardDetails {
        return RyftDropInCardDetails(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            cvc: cvc,
            cardNumberState: cardNumberState,
            expirationState: expirationState,
            cvcState: state
        )
    }

     static let incomplete = RyftDropInCardDetails(
        cardNumber: "",
        expirationMonth: "",
        expirationYear: "",
        cvc: "",
        cardNumberState: .incomplete,
        expirationState: .incomplete,
        cvcState: .incomplete
    )
}
