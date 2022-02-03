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
    }

    func test_toJson_shouldReturnExpectedValue() {
        let result = AttemptPaymentRequest.fromCard(
            clientSecret: "secret",
            number: "4242424242424242",
            expiryMonth: "10",
            expiryYear: "2028",
            cvc: "100"
        ).toJson()
        XCTAssertNotNil(result["clientSecret"])
        XCTAssertNotNil(result["cardDetails"])
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
}
