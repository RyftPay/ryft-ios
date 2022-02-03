public struct AttemptPaymentRequest {

    let clientSecret: String
    let cardDetails: PaymentRequestCardDetails?

    public static func fromCard(
        clientSecret: String,
        number: String,
        expiryMonth: String,
        expiryYear: String,
        cvc: String
    ) -> AttemptPaymentRequest {
        return AttemptPaymentRequest(
            clientSecret: clientSecret,
            cardDetails: PaymentRequestCardDetails(
                number: number,
                expiryMonth: expiryMonth,
                expiryYear: expiryYear,
                cvc: cvc
            )
        )
    }

    public struct PaymentRequestCardDetails: Equatable, Hashable {

        let number: String
        let expiryMonth: String
        let expiryYear: String
        let cvc: String

        func toJson() -> [String: Any] {
            return [
                "number": number,
                "expiryMonth": expiryMonth,
                "expiryYear": expiryYear,
                "cvc": cvc
            ]
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(number)
            hasher.combine(expiryMonth)
            hasher.combine(expiryYear)
            hasher.combine(cvc)
        }

        public static func == (lhs: PaymentRequestCardDetails, rhs: PaymentRequestCardDetails) -> Bool {
            return lhs.number == rhs.number
                && lhs.expiryMonth == rhs.expiryMonth
                && lhs.expiryYear == rhs.expiryYear
                && lhs.cvc == rhs.cvc
        }
    }

    func toJson() -> [String: Any] {
        var json: [String: Any] = [
            "clientSecret": clientSecret
        ]
        if let card = cardDetails {
            json["cardDetails"] = card.toJson() as Any
        }
        return json
    }
}
