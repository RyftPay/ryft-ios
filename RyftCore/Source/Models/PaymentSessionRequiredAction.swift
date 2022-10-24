public struct PaymentSessionRequiredAction: Codable {

    public let type: PaymentSessionActionType
    public let identify: RequiredActionIdentifyApp?

    public init(
        type: PaymentSessionActionType,
        identify: RequiredActionIdentifyApp?
    ) {
        self.type = type
        self.identify = identify
    }

    enum CodingKeys: String, CodingKey {
        case type
        case identify
    }
}
