public struct ChallengeAction: Codable, Equatable {

    public let threeDSServerTransactionId: String
    public let acsTransactionId: String
    public let acsRefNumber: String
    public let acsSignedContent: String

    enum CodingKeys: String, CodingKey {
        case threeDSServerTransactionId = "threeDSServerTransactionID"
        case acsTransactionId = "acsTransactionID"
        case acsRefNumber
        case acsSignedContent
    }
}
