public struct PaymentSessionRequiredAction: Codable {

    public let type: String
    public let url: String

    enum CodingKeys: String, CodingKey {
        case type
        case url
    }
}
