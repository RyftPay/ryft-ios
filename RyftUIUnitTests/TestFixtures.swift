import RyftCore

final class TestFixtures {

    static func paymentSession(
        customerEmail: String? = nil,
        challengeAction: ChallengeAction? = nil
    ) -> PaymentSession {
        let requiredAction = challengeAction.map {
            PaymentSessionRequiredAction(type: .challenge, identify: nil, challenge: $0)
        }
        return PaymentSession(
            id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
            amount: 350,
            currency: "GBP",
            status: requiredAction == nil ? .approved : .pendingAction,
            customerEmail: customerEmail,
            lastError: nil,
            requiredAction: requiredAction,
            returnUrl: "https://ryftpay.com",
            createdTimestamp: 123
        )
    }

    static func identifyAction() -> PaymentSessionRequiredAction {
        PaymentSessionRequiredAction(
            type: .identify,
            identify: RequiredActionIdentifyApp(
                ravelinPublicKey: "pk_test_ravelin_123",
                protocolVersion: "2.2.0",
                scheme: "mastercard",
                paymentMethodId: "pmt_01FCTS1XMKH9FF43CAFA4CXT3P"
            )
        )
    }

    static func challengeAction() -> ChallengeAction {
        ChallengeAction(
            threeDSServerTransactionId: "3ds_txn_123",
            acsTransactionId: "acs_txn_123",
            acsRefNumber: "acs_ref_123",
            acsSignedContent: "acs_signed_content"
        )
    }

    static func threeDsTransactionParams() -> ThreeDsTransactionParams {
        ThreeDsTransactionParams(
            sdkTransactionId: "sdk_txn_123",
            sdkApplicationId: "sdk_app_123",
            sdkEncryptedData: "sdk_enc_data",
            sdkEphemeralPublicKey: "sdk_epk_123",
            sdkReferenceNumber: "sdk_ref_123"
        )
    }
}
