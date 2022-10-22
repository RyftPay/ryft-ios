public struct PaymentRequestPaymentMethod: Equatable, Hashable {

    public let id: String
    public let cvv: String?

    public init(
        id: String,
        cvv: String? = nil
    ) {
        self.id = id
        self.cvv = cvv
    }

    func toJson() -> [String: Any] {
        var json = ["id": id]
        if let cvv = cvv {
            json["cvv"] = cvv
        }
        return json
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(cvv)
    }

    public static func == (
        lhs: PaymentRequestPaymentMethod,
        rhs: PaymentRequestPaymentMethod
    ) -> Bool {
        lhs.id == rhs.id && lhs.cvv == rhs.cvv
    }
}
