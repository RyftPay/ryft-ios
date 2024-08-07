import Foundation

public struct Currency: Equatable, Hashable {

    public let code: String
    public let minorUnits: Int

    public init(code: String, minorUnits: Int) {
        self.code = code
        self.minorUnits = minorUnits
    }

    public func dividor() -> Double {
        return NSDecimalNumber(decimal: pow(10, minorUnits)).doubleValue
    }

    public static func from(code: String) -> Currency {
        assert(allCurrencyCodes.contains(code), "code must be a valid ISO 4217 alphabetic code")
        return Currency(
            code: code,
            minorUnits: CurrencyUtility.minorUnits(from: code)
        )
    }

    public static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code &&
            lhs.minorUnits == rhs.minorUnits
    }

    public static let allCurrencyCodes = Set(Locale.isoCurrencyCodes)
}
