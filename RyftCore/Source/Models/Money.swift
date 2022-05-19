import Foundation

public struct Money: Equatable, Hashable {

    public let currency: Currency
    public let amount: Int

    public init(currency: Currency, amount: Int) {
        self.currency = currency
        self.amount = amount
    }

    public init(currencyCode: String, amount: Int) {
        self.currency = Currency.from(code: currencyCode)
        self.amount = amount
    }

    public func calculatePercentageAmount(with percentage: Double) -> Money {
        let intermediateResult = calculatePercentagePreservingDecimal(percentage: percentage)
        return Money(currency: self.currency, amount: Int(intermediateResult))
    }

    public func amountInMajorUnits() -> NSDecimalNumber {
        return NSDecimalNumber(decimal: Decimal(amount) / Decimal(currency.dividor()))
    }

    public static func + (money: Money, pennies: Int) -> Money {
        return money + Money(currency: money.currency, amount: pennies)
    }

    public static func + (left: Money, maybeRight: Money?) -> Money {
        return left + (maybeRight ?? Money(currency: left.currency, amount: 0))
    }

    public static func + (left: Money, right: Money) -> Money {
        return Money(currency: left.currency, amount: left.amount + right.amount)
    }

    public static func - (left: Money, right: Money) -> Money {
        return Money(currency: left.currency, amount: left.amount - right.amount)
    }

    public static func > (left: Money, right: Money) -> Bool {
        return left.amount > right.amount
    }

    public static func > (left: Money, right: Int) -> Bool {
        return left.amount > right
    }

    public static func < (left: Money, right: Money) -> Bool {
        return left.amount < right.amount
    }

    public static func * (multiplier: Int, money: Money) -> Money {
        return Money(currency: money.currency, amount: money.amount * multiplier)
    }

    public static func * (money: Money, multiplier: Int) -> Money {
        return Money(currency: money.currency, amount: money.amount * multiplier)
    }

    private func calculatePercentagePreservingDecimal(percentage: Double) -> Double {
        return (Double(amount) * (percentage / currency.dividor()))
    }

    static func from(_ amount: Int, currencyCode: String) -> Money {
        let currency = Currency.from(code: currencyCode)
        return Money(currency: currency, amount: amount)
    }

    public static func == (lhs: Money, rhs: Money) -> Bool {
        return lhs.currency == rhs.currency &&
            lhs.amount == rhs.amount
    }
}
