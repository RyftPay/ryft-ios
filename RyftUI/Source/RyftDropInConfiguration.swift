import PassKit

public struct RyftDropInConfiguration {

    public let clientSecret: String
    public let accountId: String?
    public let display: RyftDropInDisplayConfig?
    public let applePay: RyftApplePayConfig?
    public let fieldCollection: RyftDropInFieldCollectionConfig?

    public init(
        clientSecret: String,
        accountId: String? = nil,
        display: RyftDropInDisplayConfig? = nil,
        applePay: RyftApplePayConfig? = nil,
        fieldCollection: RyftDropInFieldCollectionConfig? = nil
    ) {
        self.clientSecret = clientSecret
        self.accountId = accountId
        self.display = display
        self.applePay = applePay
        self.fieldCollection = fieldCollection
    }

    public struct RyftDropInDisplayConfig {

        public let payButtonTitle: String?
        public let usage: RyftUI.DropInUsage?

        public init(
            payButtonTitle: String?,
            usage: RyftUI.DropInUsage?
        ) {
            self.payButtonTitle = payButtonTitle
            self.usage = usage
        }
    }

    public struct RyftDropInFieldCollectionConfig {

        public let nameOnCard: Bool

        public init(nameOnCard: Bool) {
            self.nameOnCard = nameOnCard
        }
    }
}
