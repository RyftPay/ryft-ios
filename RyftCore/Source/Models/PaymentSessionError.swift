public enum PaymentSessionError: String, Codable {

    case insufficientFunds = "insufficient_funds"
    case declinedDoNotHonour = "declined_do_not_honour"
    case invalidCardNumber = "invalid_card_number"
    case restrictedCard = "restricted_card"
    case securityViolation = "security_violation"
    case expiredCard = "expired_card"
    case gatewayReject = "gateway_reject"
    case badTrackData = "bad_track_data"
    case threeDSecureAuthenticationFailure = "3ds_authentication_failure"
    case unknown

    public init(from decoder: Decoder) {
        let label = try? decoder.singleValueContainer().decode(String.self)
        self = PaymentSessionError(rawValue: label ?? "") ?? .unknown
    }
}
