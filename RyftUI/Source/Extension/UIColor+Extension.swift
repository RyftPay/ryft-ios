import UIKit

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    convenience init(red: Int, green: Int, blue: Int, alpha: Float) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha)
        )
    }

    convenience init(netHex: Int) {
        self.init(
            red: (netHex >> 16) & 0xff,
            green: (netHex >> 8) & 0xff,
            blue: netHex & 0xff
        )
    }

    static let selectedInputBorderColor = UIColor(netHex: 0x2581E3)
    static let invalidColor = UIColor(netHex: 0xE86161)

    static var unselectedInputBorderColor: UIColor {
        let defaultColor = UIColor(netHex: 0xD4D4D4)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                return trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x3E4042)
                    : defaultColor
            })
        }
        return defaultColor
    }

    static var emptyInputBackgroundColor: UIColor {
        let defaultColor = UIColor(netHex: 0xEBECED)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                return trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x222427)
                    : defaultColor
            })
        }
        return defaultColor
    }

    static var nonEmptyInputBackgroundColor: UIColor {
        let defaultColor = UIColor(netHex: 0xFAFAFA)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                return trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x151718)
                    : defaultColor
            })
        }
        return defaultColor
    }

    static var separatorLineColor: UIColor {
        let defaultColor = UIColor(netHex: 0xEBECED)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                return trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x4E5156)
                    : defaultColor
            })
        }
        return defaultColor
    }

    static var separatorMiddleLabelColor: UIColor {
        let defaultColor = UIColor(netHex: 0x939393)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x949494)
                    : defaultColor
            })
        }
        return defaultColor
    }

    static var cancelButtonBackgroundColor: UIColor {
        let defaultColor = UIColor(netHex: 0xD9D9D9)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                return trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x242424)
                    : defaultColor
            })
        }
        return defaultColor
    }

    static var cancelButtonBorderColor: UIColor {
        let defaultColor = UIColor(netHex: 0xC2C2C2)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                return trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x3E4042)
                    : defaultColor
            })
        }
        return defaultColor
    }

    static var cancelButtonTitleColor: UIColor {
        let defaultColor = UIColor(netHex: 0x333333)
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                return trait.userInterfaceStyle == .dark
                    ? UIColor(netHex: 0x949494)
                    : defaultColor
            })
        }
        return defaultColor
    }
}
