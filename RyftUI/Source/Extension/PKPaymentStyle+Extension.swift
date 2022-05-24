import PassKit

extension PKPaymentButtonStyle {

    static var backwardsCompatible: PKPaymentButtonStyle {
        if #available(iOS 14.0, *) {
            return .automatic
        }
        return .black
    }
}
