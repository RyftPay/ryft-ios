public struct RequiredActionIdentifyApp: Codable, Equatable, Hashable {

    public let sessionId: String
    public let sessionSecret: String
    public let scheme: String
    public let paymentMethodId: String

    public init(
        sessionId: String,
        sessionSecret: String,
        scheme: String,
        paymentMethodId: String
    ) {
        self.sessionId = sessionId
        self.sessionSecret = sessionSecret
        self.scheme = scheme
        self.paymentMethodId = paymentMethodId
    }

    public static func == (
        lhs: RequiredActionIdentifyApp,
        rhs: RequiredActionIdentifyApp
    ) -> Bool {
        lhs.sessionId == rhs.sessionId &&
            lhs.sessionSecret == rhs.sessionSecret &&
        lhs.scheme == rhs.scheme &&
        lhs.paymentMethodId == rhs.paymentMethodId
    }

    enum CodingKeys: String, CodingKey {
        case sessionId
        case sessionSecret
        case scheme
        case paymentMethodId
    }
}
