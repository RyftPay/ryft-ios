import PassKit
import RyftCore

public final class RyftUI {

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
        guard element.message.starts(with: "billingAddress") ||
            element.message.starts(with: "customerDetails") else {
            return nil
        }
        let parts = element.message.components(separatedBy: ".")
        guard parts.count > 1 else {
            return nil
        }
        guard let field = parts[1].components(separatedBy: " ").first else {
            return nil
        }
        var error: Error?
        switch field {
        case "email":
            error = PKPaymentRequest.paymentContactInvalidError(
                withContactField: .emailAddress,
                localizedDescription: element.message
            )
        case "firstName", "lastName":
            error = NSError(
                domain: PKPaymentErrorDomain,
                code: PKPaymentError.billingContactInvalidError.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: element.message,
                    PKPaymentErrorKey.contactFieldUserInfoKey.rawValue: PKContactField.name
                ]
            )
        case "lineOne":
            error = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressStreetKey,
                localizedDescription: element.message
            )
        case "city":
            error = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressCityKey,
                localizedDescription: element.message
            )
        case "country":
            error = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressCountryKey,
                localizedDescription: element.message
            )
        case "postalCode":
            error = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressPostalCodeKey,
                localizedDescription: element.message
            )
        case "region":
            error = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressStateKey,
                localizedDescription: element.message
            )
        default:
            break
        }
        return error
    }
}
