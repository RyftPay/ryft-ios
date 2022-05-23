import RyftCore
import PassKit

extension PaymentSession {

    func toPKPayment(
        merchantIdentifier: String,
        merchantCountry: String,
        merchantName: String
    ) -> PKPaymentRequest {
        let payment = PKPaymentRequest()
        payment.merchantIdentifier = merchantIdentifier
        payment.merchantCapabilities = .capability3DS
        payment.countryCode = merchantCountry
        payment.currencyCode = self.currency
        payment.supportedNetworks = [.visa, .masterCard]
        payment.paymentSummaryItems = [
            PKPaymentSummaryItem(
                label: merchantName,
                amount: self.amountAsMoney().amountInMajorUnits(),
                type: .final
            )
        ]
        payment.requiredBillingContactFields = [.postalAddress]
        payment.requiredShippingContactFields = customerEmail == nil ? [.emailAddress] : []
        return payment
    }
}
