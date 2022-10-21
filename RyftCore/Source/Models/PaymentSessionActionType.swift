public enum PaymentSessionActionType: String, Codable {

    case unknown
    case identify = "Identify"

    public init(from decoder: Decoder) {
        let label = try? decoder.singleValueContainer().decode(String.self)
        self = PaymentSessionActionType(rawValue: label ?? "") ?? .unknown
    }
}
