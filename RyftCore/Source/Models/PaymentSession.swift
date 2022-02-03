public struct PaymentSession: Codable {

    public let id: String
    public let status: PaymentSessionStatus
    public let lastError: PaymentSessionError?
    public let requiredAction: PaymentSessionRequiredAction?
    public let returnUrl: String
    public let createdTimestamp: Int64

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case lastError
        case requiredAction
        case returnUrl
        case createdTimestamp
    }
}
