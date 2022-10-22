public struct PaymentSessionRequiredAction: Codable {

    public let type: PaymentSessionActionType
    public let url: String?
    public let identify: RequiredActionIdentifyApp?

    public init(
        type: PaymentSessionActionType,
        url: String?,
        identify: RequiredActionIdentifyApp?
    ) {
        self.type = type
        self.url = url
        self.identify = identify
    }

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case identify
    }
}
