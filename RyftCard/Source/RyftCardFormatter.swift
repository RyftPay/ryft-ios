import Foundation

public final class RyftCardFormatter {

    public static func sanitisedOnlyDigits(value: String) -> String {
        return value.numericsOnly()
    }

    public static func sanitisedExpiration(expiration: String) -> (month: String, year: String) {
        let digitOnlyExpiration = expiration.numericsOnly()
        let month = String(digitOnlyExpiration.prefix(2))
        if digitOnlyExpiration.count <= 2 {
            return (month: month, year: "")
        }
        return (
            month: month,
            year: String(digitOnlyExpiration.suffix(digitOnlyExpiration.count - 2))
        )
    }

    // swiftlint:disable reduce_into
    public static func format(cardNumber: String, with cardType: RyftCardType) -> String {
        var index = 0
        var numberOfGaps = 0
        return cardNumber.reduce("") {
            defer { index += 1 }
            guard cardType.cardNumberFormatGaps.count > numberOfGaps else {
                return "\($0)\($1)"
            }
            if index == cardType.cardNumberFormatGaps[numberOfGaps] {
                numberOfGaps += 1
                return "\($0) \($1)"
            }
            return "\($0)\($1)"
        }
    }
    // swiftlint:enable reduce_into

    public static func sanitisedName(value: String) -> String {
        value.trimmingCharacters(in: .whitespaces)
    }
}
