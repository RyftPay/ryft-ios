public struct RyftApplePayConfig {

    public let merchantIdentifier: String
    public let merchantCountryCode: String
    public let merchantName: String

    public init(
        merchantIdentifier: String,
        merchantCountryCode: String,
        merchantName: String
    ) {
        self.merchantIdentifier = merchantIdentifier
        self.merchantCountryCode = merchantCountryCode
        self.merchantName = merchantName
    }
}
