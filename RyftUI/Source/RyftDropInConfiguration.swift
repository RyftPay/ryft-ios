public struct RyftDropInConfiguration {

    public let clientSecret: String
    public let accountId: String?
    public let display: RyftDropInDisplayConfig?

    public init(
        clientSecret: String,
        accountId: String? = nil,
        display: RyftDropInDisplayConfig? = nil
    ) {
        self.clientSecret = clientSecret
        self.accountId = accountId
        self.display = display
    }

    public struct RyftDropInDisplayConfig {

        public let payButtonTitle: String?

        public init(payButtonTitle: String?) {
            self.payButtonTitle = payButtonTitle
        }
    }
}
