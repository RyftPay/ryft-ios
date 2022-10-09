import XCTest

@testable import RyftCore

final class PaymentRequestPaymentMethodOptionsTests: XCTestCase {

    func test_init_shouldReturnExpectedValue() {
        let result = PaymentRequestPaymentMethodOptions(store: true)
        XCTAssertTrue(result.store)
    }

    func test_toJson_shouldReturnExpectedValue() {
        let value = PaymentRequestPaymentMethodOptions(store: true)
        let result = value.toJson()
        guard let store = result["store"] as? Bool else {
            XCTFail("serialized JSON store field was not expected type")
            return
        }
        XCTAssertTrue(store)
    }
}
