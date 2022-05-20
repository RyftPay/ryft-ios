import PassKit
import RyftCore

final public class RyftUI {

    public static let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard]

    public static func supportsApplePay() -> Bool {
        PKPaymentAuthorizationController
            .canMakePayments(usingNetworks: supportedNetworks)
    }

    static func pkPaymentErrors(_ error: Error?) -> [Error] {
        guard let httpError = error as? HttpError else {
            return []
        }
        switch httpError {
        case .badResponse(let detail):
            return detail.body.errors.compactMap { pkPaymentError($0) }
        default:
            return []
        }
    }

    static func pkPaymentError(
        _ element: RyftApiError.RyftApiErrorElement
    ) -> Error? {
        guard element.message.starts(with: "billingAddress") else {
            return nil
        }
        let parts = element.message.components(separatedBy: ".")
        guard parts.count > 1 else {
            return nil
        }
        guard let field = parts[1].components(separatedBy: " ").first else {
            return nil
        }
        var billingAddressError: Error? = nil
        switch field {
        case "firstName", "lastName":
            billingAddressError = NSError(
                domain: PKPaymentErrorDomain,
                code: PKPaymentError.billingContactInvalidError.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: element.message,
                    PKPaymentErrorKey.contactFieldUserInfoKey.rawValue: PKContactField.name
                ]
            )
        case "lineOne":
            billingAddressError = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressStreetKey,
                localizedDescription: element.message
            )
        case "city":
            billingAddressError = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressCityKey,
                localizedDescription: element.message
            )
        case "country":
            billingAddressError = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressCountryKey,
                localizedDescription: element.message
            )
        case "postalCode":
            billingAddressError = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressPostalCodeKey,
                localizedDescription: element.message
            )
        case "region":
            billingAddressError = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressStateKey,
                localizedDescription: element.message
            )
        default:
            break
        }
        return billingAddressError
    }
}
