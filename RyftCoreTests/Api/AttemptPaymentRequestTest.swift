import XCTest

@testable import RyftCore

class AttemptPaymentRequestTest: XCTestCase {

    func test_fromCard_shouldReturnExpectedValue() {
        let value = AttemptPaymentRequest.fromCard(
            clientSecret: "secret",
            number: "4242424242424242",
            expiryMonth: "10",
            expiryYear: "2028",
            cvc: "100"
        )
        let expectedCardDetails = AttemptPaymentRequest.PaymentRequestCardDetails(
            number: "4242424242424242",
            expiryMonth: "10",
            expiryYear: "2028",
            cvc: "100"
        )
        XCTAssertTrue(value.clientSecret == "secret")
        XCTAssertTrue(value.cardDetails == expectedCardDetails)
        XCTAssertNil(value.walletDetails)
    }

    func test_fromApplePay_shouldReturnExpectedValue() {
        let value = AttemptPaymentRequest.fromApplePay(
            clientSecret: "secret",
            applePayToken: "base64-encoded-apple-pay-token"
        )
        let expectedWalletDetails = AttemptPaymentRequest.PaymentRequestWalletDetails(
            type: "ApplePay",
            applePayToken: "base64-encoded-apple-pay-token"
        )
        XCTAssertTrue(value.clientSecret == "secret")
        XCTAssertTrue(value.walletDetails == expectedWalletDetails)
        XCTAssertNil(value.cardDetails)
    }

    func test_toJson_shouldReturnExpectedValue_forCardPayment() {
        let result = AttemptPaymentRequest.fromCard(
            clientSecret: "secret",
            number: "4242424242424242",
            expiryMonth: "10",
            expiryYear: "2028",
            cvc: "100"
        ).toJson()
        XCTAssertNotNil(result["clientSecret"])
        XCTAssertNotNil(result["cardDetails"])
        XCTAssertNil(result["walletDetails"])
        guard let clientSecret = result["clientSecret"] as? String else {
            XCTFail("serialized JSON clientSecret field was not expected type")
            return
        }
        guard let cardDetails = result["cardDetails"] as? [String: Any] else {
            XCTFail("serialized JSON cardDetails field was not expected type")
            return
        }
        guard
            let cardNumber = cardDetails["number"] as? String,
            let cardExpiryMonth = cardDetails["expiryMonth"] as? String,
            let cardExpiryYear = cardDetails["expiryYear"] as? String,
            let cardCvc = cardDetails["cvc"] as? String
        else {
            XCTFail("serialized JSON cardDetails did not contain the expected fields")
            return
        }
        XCTAssertEqual("secret", clientSecret)
        XCTAssertEqual("4242424242424242", cardNumber)
        XCTAssertEqual("10", cardExpiryMonth)
        XCTAssertEqual("2028", cardExpiryYear)
        XCTAssertEqual("100", cardCvc)
    }

    func test_toJson_shouldReturnExpectedValue_forApplePayPayment() {
        let result = AttemptPaymentRequest.fromApplePay(
            clientSecret: "secret",
            applePayToken: "base64-encoded-apple-pay-token"
        ).toJson()
        XCTAssertNotNil(result["clientSecret"])
        XCTAssertNotNil(result["walletDetails"])
        XCTAssertNil(result["cardDetails"])
        guard let clientSecret = result["clientSecret"] as? String else {
            XCTFail("serialized JSON clientSecret field was not expected type")
            return
        }
        guard let walletDetails = result["walletDetails"] as? [String: Any] else {
            XCTFail("serialized JSON walletDetails field was not expected type")
            return
        }
        guard
            let walletType = walletDetails["type"] as? String,
            let applePayToken = walletDetails["applePayToken"] as? String
        else {
            XCTFail("serialized JSON walletDetails did not contain the expected fields")
            return
        }
        XCTAssertEqual("secret", clientSecret)
        XCTAssertEqual("ApplePay", walletType)
        XCTAssertEqual("base64-encoded-apple-pay-token", applePayToken)
    }
}
