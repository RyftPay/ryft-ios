public struct PaymentRequestPaymentMethodOptions: Equatable, Hashable {

    let store: Bool

    public init(store: Bool) {
        self.store = store
    }

    func toJson() -> [String: Any] {
        ["store": store]
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(store)
    }

    public static func == (
        lhs: PaymentRequestPaymentMethodOptions,
        rhs: PaymentRequestPaymentMethodOptions
    ) -> Bool {
        lhs.store == rhs.store
    }
}
