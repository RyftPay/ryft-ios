public struct ChallengeAction: Codable, Equatable {

    public let threeDSServerTransactionId: String
    public let acsTransactionId: String
    public let acsRefNumber: String
    public let acsSignedContent: String

    public init(
        threeDSServerTransactionId: String,
        acsTransactionId: String,
        acsRefNumber: String,
        acsSignedContent: String
    ) {
        self.threeDSServerTransactionId = threeDSServerTransactionId
        self.acsTransactionId = acsTransactionId
        self.acsRefNumber = acsRefNumber
        self.acsSignedContent = acsSignedContent
    }

    enum CodingKeys: String, CodingKey {
        case threeDSServerTransactionId = "threeDSServerTransactionID"
        case acsTransactionId = "acsTransactionID"
        case acsRefNumber
        case acsSignedContent
    }
}
