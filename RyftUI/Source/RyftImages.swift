import UIKit
import RyftCard

public final class RyftImages {

    public static let amexIcon = getImage(named: "amex_icon")
    public static let visaIcon = getImage(named: "visa_icon")
    public static let mastercardIcon = getImage(named: "mastercard_icon")
    public static let cvcIcon = getImage(named: "cvc_icon")
    public static let unknownCardIcon = getImage(named: "unknown_card_icon")

    static let checkboxUnselected = getImage(named: "checkbox_unselected")
    static let checkboxSelected = getImage(named: "checkbox_selected")

    static func imageFor(cardScheme: CardScheme) -> UIImage? {
        switch cardScheme {
        case .visa:
            return visaIcon
        case .mastercard:
            return mastercardIcon
        case .amex:
            return amexIcon
        default:
            return unknownCardIcon
        }
    }

    private static func getImage(named: String) -> UIImage? {
        #if SWIFT_PACKAGE
        return UIImage(named: named, in: .module, compatibleWith: nil)
        #endif
        return UIImage(
            named: named,
            in: Bundle(for: RyftImages.self),
            compatibleWith: nil
        )
    }
}
