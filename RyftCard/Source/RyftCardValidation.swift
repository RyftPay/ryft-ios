import Foundation

public final class RyftCardValidation {

    private static let cardholderNameMaxLength = 120
    private static let minimumNumberOfWordsInCardholderName = 2

    public static func determineCardType(cardNumber: String?) -> RyftCardType {
        guard let cardNumber = cardNumber else {
            return RyftCardType.unknown
        }
        let sanitisedCardNumber = cardNumber.numericsOnly()
        guard !sanitisedCardNumber.isEmpty else {
            return RyftCardType.unknown
        }
        let matchingCardTypes = RyftCardType.cardTypes.values.filter { cardType in
            return cardType.binRanges.contains { binRange in
                let minCardSegmentToBinCheck = Int(sanitisedCardNumber.prefix(String(binRange.min).count))
                let maxCardSegmentToBinCheck = Int(sanitisedCardNumber.prefix(String(binRange.max).count))
                let passesMinCheck = minCardSegmentToBinCheck != nil
                    && minCardSegmentToBinCheck! >= binRange.min
                    && minCardSegmentToBinCheck! <= binRange.max
                let passesMaxCheck = maxCardSegmentToBinCheck != nil
                    && maxCardSegmentToBinCheck! >= binRange.min
                    && maxCardSegmentToBinCheck! <= binRange.max
                return passesMinCheck || passesMaxCheck
            }
        }
        if matchingCardTypes.count == 1 {
            return matchingCardTypes.first!
        }
        return RyftCardType.unknown
    }

    public static func validate(
        cardNumber: String,
        with cardType: RyftCardType
    ) -> RyftInputValidationState {
        let sanitisedCardNumber = cardNumber.numericsOnly()
        guard !sanitisedCardNumber.isEmpty else {
            return .incomplete
        }
        if cardType.scheme == .unknown {
            return .invalid
        }
        let maxCardLengthForCardType = cardType.cardLengths.max() ?? 0
        if sanitisedCardNumber.count < maxCardLengthForCardType {
            return .incomplete
        }
        if sanitisedCardNumber.count > maxCardLengthForCardType {
            return .invalid
        }
        return luhnCheck(cardNumber: sanitisedCardNumber) ? .valid : .invalid
    }

    public static func validate(
        expirationMonth: String,
        expirationYear: String
    ) -> RyftInputValidationState {
        if expirationMonth.isNonNumeric() || expirationYear.isNonNumeric() {
            return .invalid
        }
        let monthState = validate(expirationMonth: expirationMonth)
        let yearState = validate(expirationYear: expirationYear)
        if monthState == .invalid || yearState == .invalid {
            return .invalid
        }
        if monthState == .incomplete || yearState == .incomplete {
            return .incomplete
        }
        return .valid
    }

    private static func validate(expirationMonth: String) -> RyftInputValidationState {
        if expirationMonth.isNonNumeric() {
            return .invalid
        }
        let sanitisedMonth = expirationMonth.numericsOnly()
        switch sanitisedMonth.count {
        case 0:
            return .incomplete
        case 1:
            return sanitisedMonth == "0" || sanitisedMonth == "1"
                ? .incomplete
                : .invalid
        case 2:
            return (1...12).contains(Int(sanitisedMonth) ?? 0)
                ? .valid
                : .invalid
        default:
            return .invalid
        }
    }

    private static func validate(expirationYear: String) -> RyftInputValidationState {
        if expirationYear.isNonNumeric() {
            return .invalid
        }
        let currentYear = DateUtility.currentYear()
        let yearDigits = String(currentYear).compactMap { $0.wholeNumberValue }
        let decade = yearDigits[0]
        let sanitisedYear = expirationYear.numericsOnly()
        switch sanitisedYear.count {
        case 0:
            return .incomplete
        case 1:
            return Int(sanitisedYear) ?? 0 >= decade ? .incomplete : .invalid
        case 2:
            return Int(sanitisedYear) ?? 0 >= currentYear ? .valid : .invalid
        default:
            return .invalid
        }
    }

    public static func validate(
        cvc: String,
        with cardType: RyftCardType
    ) -> RyftInputValidationState {
        if cvc.isNonNumeric() {
            return .invalid
        }
        if cardType.scheme == .unknown {
            return .incomplete
        }
        switch NSNumber(value: cvc.count)
            .compare(NSNumber(value: cardType.cvcLength)) {
        case .orderedSame:
            return .valid
        case .orderedAscending:
            return .incomplete
        default:
            return .invalid
        }
    }

    public static func validate(cardholderName: String) -> RyftInputValidationState {
        let words = cardholderName.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if cardholderName.count > cardholderNameMaxLength {
            return .invalid
        }
        if words.count < minimumNumberOfWordsInCardholderName {
            return .incomplete
        }
        return .valid
    }

    public static func luhnCheck(cardNumber: String) -> Bool {
        var sum = 0
        let digitStrings = cardNumber.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum.isMultiple(of: 10)
    }
}
