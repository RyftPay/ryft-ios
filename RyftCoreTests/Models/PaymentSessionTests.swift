import XCTest

@testable import RyftCore

class PaymentSessionTests: XCTestCase {

    func test_amountAsMoney_shouldReturnExpectedValue() {
        let paymentSession = TestFixtures.paymentSession()
        let expected = Money(
            currencyCode: paymentSession.currency,
            amount: paymentSession.amount
        )
        XCTAssertEqual(expected, paymentSession.amountAsMoney())
    }

    func test_fromJson_shouldReturnExpectedResult_whenPaymentIsPendingPayment() {
        let rawJson = """
            {
                "id": "ps_01G3908XF27DA1YTJXKM0HGJVB",
                "amount": 4201,
                "currency": "GBP",
                "returnUrl": "https://ryftpay.com",
                "status": "PendingPayment",
                "createdTimestamp": 1652790949
            }
        """
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(PaymentSession.self, from: rawJson.data(using: .utf8)!) else {
            XCTFail("expected non-nil result, but JSON deserialisation gave nil")
            return
        }
        XCTAssertEqual("ps_01G3908XF27DA1YTJXKM0HGJVB", result.id)
        XCTAssertEqual(4201, result.amount)
        XCTAssertEqual("GBP", result.currency)
        XCTAssertEqual("https://ryftpay.com", result.returnUrl)
        XCTAssertEqual(PaymentSessionStatus.pendingPayment, result.status)
        XCTAssertEqual(1652790949, result.createdTimestamp)
    }

    func test_fromJson_shouldReturnExpectedResult_whenPaymentIsPendingAction() {
        let rawJson = """
            {
                "id": "ps_01G3908XF27DA1YTJXKM0HGJVB",
                "amount": 4201,
                "currency": "GBP",
                "returnUrl": "https://ryftpay.com",
                "status": "PendingAction",
                "requiredAction": {
                    "type": "Identify",
                    "identify": {
                        "ravelinPublicKey": "pk_test_ravelin_123",
                        "protocolVersion": "2.2.0",
                        "scheme": "mastercard",
                        "paymentMethodId": "pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ"
                    }
                },
                "createdTimestamp": 1652790949
            }
        """
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(PaymentSession.self, from: rawJson.data(using: .utf8)!) else {
            XCTFail("expected non-nil result, but JSON deserialisation gave nil")
            return
        }
        XCTAssertEqual("ps_01G3908XF27DA1YTJXKM0HGJVB", result.id)
        XCTAssertEqual(4201, result.amount)
        XCTAssertEqual("GBP", result.currency)
        XCTAssertEqual("https://ryftpay.com", result.returnUrl)
        XCTAssertEqual(PaymentSessionStatus.pendingAction, result.status)
        XCTAssertEqual(.identify, result.requiredAction?.type)
        XCTAssertEqual("pk_test_ravelin_123", result.requiredAction?.identify?.ravelinPublicKey)
        XCTAssertEqual("2.2.0", result.requiredAction?.identify?.protocolVersion)
        XCTAssertEqual("mastercard", result.requiredAction?.identify?.scheme)
        XCTAssertEqual(
            "pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ",
            result.requiredAction?.identify?.paymentMethodId
        )
        XCTAssertEqual(1652790949, result.createdTimestamp)
    }

    func test_fromJson_shouldReturnExpectedResult_whenPaymentIsPendingAction_withChallengeAction() {
        let rawJson = """
            {
                "id": "ps_01G3908XF27DA1YTJXKM0HGJVB",
                "amount": 4201,
                "currency": "GBP",
                "returnUrl": "https://ryftpay.com",
                "status": "PendingAction",
                "requiredAction": {
                    "type": "Challenge",
                    "challenge": {
                        "threeDSServerTransactionID": "3ds_txn_123",
                        "acsTransactionID": "acs_txn_123",
                        "acsRefNumber": "acs_ref_123",
                        "acsSignedContent": "acs_signed_content"
                    }
                },
                "createdTimestamp": 1652790949
            }
        """
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(PaymentSession.self, from: rawJson.data(using: .utf8)!) else {
            XCTFail("expected non-nil result, but JSON deserialisation gave nil")
            return
        }
        XCTAssertEqual(PaymentSessionStatus.pendingAction, result.status)
        XCTAssertEqual(.challenge, result.requiredAction?.type)
        XCTAssertNil(result.requiredAction?.identify)
        XCTAssertEqual("3ds_txn_123", result.requiredAction?.challenge?.threeDSServerTransactionId)
        XCTAssertEqual("acs_txn_123", result.requiredAction?.challenge?.acsTransactionId)
        XCTAssertEqual("acs_ref_123", result.requiredAction?.challenge?.acsRefNumber)
        XCTAssertEqual("acs_signed_content", result.requiredAction?.challenge?.acsSignedContent)
    }
}
