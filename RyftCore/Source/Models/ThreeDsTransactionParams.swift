public struct ThreeDsTransactionParams {

    public let sdkTransactionId: String
    public let sdkApplicationId: String
    public let sdkEncryptedData: String
    public let sdkEphemeralPublicKey: String
    public let sdkReferenceNumber: String

    public init(
        sdkTransactionId: String,
        sdkApplicationId: String,
        sdkEncryptedData: String,
        sdkEphemeralPublicKey: String,
        sdkReferenceNumber: String
    ) {
        self.sdkTransactionId = sdkTransactionId
        self.sdkApplicationId = sdkApplicationId
        self.sdkEncryptedData = sdkEncryptedData
        self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
        self.sdkReferenceNumber = sdkReferenceNumber
    }
}
