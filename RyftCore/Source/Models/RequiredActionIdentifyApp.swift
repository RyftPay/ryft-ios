public struct RequiredActionIdentifyApp: Codable {

    public let sessionId: String
    public let sessionSecret: String
    public let scheme: String
    public let paymentMethodId: String

    enum CodingKeys: String, CodingKey {
        case sessionId
        case sessionSecret
        case scheme
        case paymentMethodId
    }
}
