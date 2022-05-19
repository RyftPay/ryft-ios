import Foundation

public final class CurrencyUtility {

    public static func minorUnits(from alphabeticCurrencyCode: String) -> Int {
        switch alphabeticCurrencyCode {
        case "BIF", "CLP":
            return 0
        case "AFN", "ALL", "COP", "IDR", "IRR", "KPW", "LAK", "LBP", "MMK", "MGA", "PKR", "RSD", "SYP", "SOS", "SLL", "YER":
            return 2
        case "BHD", "IQD":
            return 3
        default:
            return currencyFormatter(
                currencyCode: alphabeticCurrencyCode
            ).maximumFractionDigits
        }
    }

    private static func currencyFormatter(currencyCode: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter
    }
}
