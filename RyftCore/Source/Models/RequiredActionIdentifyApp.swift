public struct RequiredActionIdentifyApp: Codable, Equatable, Hashable {

    public let ravelinPublicKey: String
    public let protocolVersion: String
    public let scheme: String
    public let paymentMethodId: String

    public init(
        ravelinPublicKey: String,
        protocolVersion: String,
        scheme: String,
        paymentMethodId: String
    ) {
        self.ravelinPublicKey = ravelinPublicKey
        self.protocolVersion = protocolVersion
        self.scheme = scheme
        self.paymentMethodId = paymentMethodId
    }

    public static func == (
        lhs: RequiredActionIdentifyApp,
        rhs: RequiredActionIdentifyApp
    ) -> Bool {
        lhs.ravelinPublicKey == rhs.ravelinPublicKey &&
            lhs.protocolVersion == rhs.protocolVersion &&
        lhs.scheme == rhs.scheme &&
        lhs.paymentMethodId == rhs.paymentMethodId
    }

    enum CodingKeys: String, CodingKey {
        case ravelinPublicKey
        case protocolVersion
        case scheme
        case paymentMethodId
    }
}
