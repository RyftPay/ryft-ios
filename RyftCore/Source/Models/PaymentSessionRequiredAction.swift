public struct PaymentSessionRequiredAction: Codable {

    public let type: PaymentSessionActionType
    public let identify: RequiredActionIdentifyApp?
    public let challenge: ChallengeAction?

    public init(
        type: PaymentSessionActionType,
        identify: RequiredActionIdentifyApp?,
        challenge: ChallengeAction? = nil
    ) {
        self.type = type
        self.identify = identify
        self.challenge = challenge
    }

    enum CodingKeys: String, CodingKey {
        case type
        case identify
        case challenge
    }
}
