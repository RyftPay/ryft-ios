public enum PaymentSessionStatus: String, Codable {

    case unknown
    case pendingPayment = "PendingPayment"
    case pendingAction = "PendingAction"
    case approved = "Approved"
    case captured = "Captured"

    public init(from decoder: Decoder) {
        let label = try? decoder.singleValueContainer().decode(String.self)
        self = PaymentSessionStatus(rawValue: label ?? "") ?? .unknown
    }
}
