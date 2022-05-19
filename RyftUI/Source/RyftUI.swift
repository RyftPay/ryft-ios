import PassKit

final public class RyftUI {

    public static let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard]

    public static func supportsApplePay() -> Bool {
        PKPaymentAuthorizationController
            .canMakePayments(usingNetworks: supportedNetworks)
    }
}
