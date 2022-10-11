public struct PaymentSessionRequiredAction: Codable {

    public let type: String
    public let url: String?
    public let identify: RequiredActionIdentifyApp?

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case identify
    }
}
