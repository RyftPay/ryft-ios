import PassKit

public struct AttemptPaymentRequest {

    let clientSecret: String
    let cardDetails: PaymentRequestCardDetails?
    let walletDetails: PaymentRequestWalletDetails?
    let billingAddress: BillingAddress?
    let customerDetails: PaymentRequestCustomerDetails?

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
            ),
            walletDetails: nil,
            billingAddress: nil,
            customerDetails: nil
        )
    }

    public static func fromApplePay(
        clientSecret: String,
        applePayToken: String,
        billingAddress: BillingAddress?,
        customerDetails: PaymentRequestCustomerDetails?
    ) -> AttemptPaymentRequest {
        AttemptPaymentRequest(
            clientSecret: clientSecret,
            cardDetails: nil,
            walletDetails: PaymentRequestWalletDetails(
                type: "ApplePay",
                applePayToken: applePayToken
            ),
            billingAddress: billingAddress,
            customerDetails: customerDetails
        )
    }

    public struct PaymentRequestCardDetails: Equatable, Hashable {

        let number: String
        let expiryMonth: String
        let expiryYear: String
        let cvc: String

        func toJson() -> [String: Any] {
            [
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

    public struct PaymentRequestWalletDetails: Equatable, Hashable {

        let type: String
        let applePayToken: String

        func toJson() -> [String: Any] {
            [
                "type": type,
                "applePayToken": applePayToken
            ]
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(type)
            hasher.combine(applePayToken)
        }

        public static func == (lhs: PaymentRequestWalletDetails, rhs: PaymentRequestWalletDetails) -> Bool {
            return lhs.type == rhs.type
                && lhs.applePayToken == rhs.applePayToken
        }
    }

    func toJson() -> [String: Any] {
        var json: [String: Any] = [
            "clientSecret": clientSecret
        ]
        if let card = cardDetails {
            json["cardDetails"] = card.toJson() as Any
        }
        if let walletDetails = walletDetails {
            json["walletDetails"] = walletDetails.toJson() as Any
        }
        if let billingAddress = billingAddress {
            json["billingAddress"] = billingAddress.toJson() as Any
        }
        if let customerDetails = customerDetails {
            json["customerDetails"] = customerDetails.toJson() as Any
        }
        return json
    }
}
