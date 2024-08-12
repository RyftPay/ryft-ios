import RyftCard

struct RyftDropInCardDetails: Equatable, Hashable {

     let cardNumber: String
     let expirationMonth: String
     let expirationYear: String
     let cvc: String
     let name: String?
     let cardNumberState: RyftInputValidationState
     let expirationState: RyftInputValidationState
     let cvcState: RyftInputValidationState
     let nameState: RyftInputValidationState

    func isValid(nameRequired: Bool) -> Bool {
        let appliedNameState: RyftInputValidationState = nameRequired ? nameState : .valid
        return [cardNumberState, expirationState, cvcState, appliedNameState].allSatisfy { $0 == .valid }
    }

     func with(
        cardNumber: String,
        and state: RyftInputValidationState
    ) -> RyftDropInCardDetails {
        RyftDropInCardDetails(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            cvc: cvc,
            name: name,
            cardNumberState: state,
            expirationState: expirationState,
            cvcState: cvcState,
            nameState: nameState
        )
    }

     func with(
        expirationMonth: String,
        expirationYear: String,
        and state: RyftInputValidationState
    ) -> RyftDropInCardDetails {
        RyftDropInCardDetails(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: "20\(expirationYear)",
            cvc: cvc,
            name: name,
            cardNumberState: cardNumberState,
            expirationState: state,
            cvcState: cvcState,
            nameState: nameState
        )
    }

     func with(
        cvc: String,
        and state: RyftInputValidationState
    ) -> RyftDropInCardDetails {
        RyftDropInCardDetails(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            cvc: cvc,
            name: name,
            cardNumberState: cardNumberState,
            expirationState: expirationState,
            cvcState: state,
            nameState: nameState
        )
    }

    func with(
        name: String,
        and state: RyftInputValidationState
    ) -> RyftDropInCardDetails {
        RyftDropInCardDetails(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            cvc: cvc,
            name: name,
            cardNumberState: cardNumberState,
            expirationState: expirationState,
            cvcState: cvcState,
            nameState: state
        )
    }

     static let incomplete = RyftDropInCardDetails(
        cardNumber: "",
        expirationMonth: "",
        expirationYear: "",
        cvc: "",
        name: nil,
        cardNumberState: .incomplete,
        expirationState: .incomplete,
        cvcState: .incomplete,
        nameState: .incomplete
    )
}
