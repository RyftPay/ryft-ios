import UIKit
import Foundation

final class NSLocalizedStringUtility {

    static let cardDropInTitle = getString(forKey: "card_drop_in_title")
    static let orWord = getString(forKey: "card_drop_in_or")
    static let cardNumberPlaceholder = getString(forKey: "card_number_placeholder")
    static let cvcPlaceholder = getString(forKey: "cvc_placeholder")
    static let expirationPlaceholder = getString(forKey: "expiration_placeholder")
    static let payNow = getString(forKey: "pay_now")
    static let cancelTitle = getString(forKey: "cancel_title")
    static let oopsWord = getString(forKey: "oops")
    static let retryWord = getString(forKey: "retry")
    static let applePayPresentError = getString(forKey: "apple_pay_present_error")

    static func getString(forKey: String) -> String {
        #if SWIFT_PACKAGE
        return Bundle.module.localizedString(forKey: forKey, value: nil, table: nil)
        #endif
        return Bundle(for: NSLocalizedStringUtility.self)
            .localizedString(forKey: forKey, value: nil, table: nil)
    }

    static func getStringWithFallback(forKey: String) -> String {
        #if SWIFT_PACKAGE
        return Bundle.module.localizedString(
            forKey: forKey,
            value: getString(forKey: "unknown"),
            table: nil
        )
        #endif
        return Bundle(for: NSLocalizedStringUtility.self)
            .localizedString(
                forKey: forKey,
                value: getString(forKey: "unknown"),
                table: nil
            )
    }
}
