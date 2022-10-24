public struct PaymentRequestPaymentMethod: Equatable, Hashable {

    public let id: String
    public let cvc: String?

    public init(
        id: String,
        cvc: String? = nil
    ) {
        self.id = id
        self.cvc = cvc
    }

    func toJson() -> [String: Any] {
        var json = ["id": id]
        if let cvc = cvc {
            json["cvc"] = cvc
        }
        return json
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(cvc)
    }

    public static func == (
        lhs: PaymentRequestPaymentMethod,
        rhs: PaymentRequestPaymentMethod
    ) -> Bool {
        lhs.id == rhs.id && lhs.cvc == rhs.cvc
    }
}
