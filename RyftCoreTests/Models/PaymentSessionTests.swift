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
                        "sessionId": "123",
                        "sessionSecret": "secret",
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
        XCTAssertEqual("123", result.requiredAction?.identify?.sessionId)
        XCTAssertEqual("secret", result.requiredAction?.identify?.sessionSecret)
        XCTAssertEqual("mastercard", result.requiredAction?.identify?.scheme)
        XCTAssertEqual(
            "pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ",
            result.requiredAction?.identify?.paymentMethodId
        )
        XCTAssertEqual(1652790949, result.createdTimestamp)
    }
}
