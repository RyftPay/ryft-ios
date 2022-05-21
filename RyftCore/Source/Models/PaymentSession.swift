public struct PaymentSession: Codable {

    public let id: String
    public let amount: Int
    public let currency: String
    public let status: PaymentSessionStatus
    public let lastError: PaymentSessionError?
    public let requiredAction: PaymentSessionRequiredAction?
    public let returnUrl: String
    public let createdTimestamp: Int64

    public init(
        id: String,
        amount: Int,
        currency: String,
        status: PaymentSessionStatus,
        lastError: PaymentSessionError?,
        requiredAction: PaymentSessionRequiredAction?,
        returnUrl: String,
        createdTimestamp: Int64
    ) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.status = status
        self.lastError = lastError
        self.requiredAction = requiredAction
        self.returnUrl = returnUrl
        self.createdTimestamp = createdTimestamp
    }

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
