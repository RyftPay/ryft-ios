import PassKit

public struct PaymentRequestCustomerDetails: Equatable, Hashable {

    let email: String

    public init(email: String) {
        self.email = email
    }

    public init?(pkContact: PKContact?) {
        guard let email = pkContact?.emailAddress else { return nil }
        self.email = email
    }

    func toJson() -> [String: Any] {
        [
            "email": email
        ]
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }

    public static func == (
        lhs: PaymentRequestCustomerDetails,
        rhs: PaymentRequestCustomerDetails
    ) -> Bool {
        lhs.email == rhs.email
    }
}
