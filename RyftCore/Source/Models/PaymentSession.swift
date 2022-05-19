public struct PaymentSession: Codable {

    public let id: String
    public let amount: Int
    public let currency: String
    public let status: PaymentSessionStatus
    public let lastError: PaymentSessionError?
    public let requiredAction: PaymentSessionRequiredAction?
    public let returnUrl: String
    public let createdTimestamp: Int64

    public func amountAsMoney() -> Money {
        Money(currencyCode: currency, amount: amount)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case currency
        case status
        case lastError
        case requiredAction
        case returnUrl
        case createdTimestamp
    }
}
