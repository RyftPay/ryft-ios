import XCTest

@testable import RyftCore

final class PaymentRequestPaymentMethodTests: XCTestCase {

    func test_init_ShouldReturnExpectedValue_withoutCvv() {
        let result = PaymentRequestPaymentMethod(id: "pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ")
        XCTAssertEqual("pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ", result.id)
        XCTAssertNil(result.cvc)
    }

    func test_init_ShouldReturnExpectedValue_withCvv() {
        let result = PaymentRequestPaymentMethod(id: "pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ", cvc: "100")
        XCTAssertEqual("pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ", result.id)
        XCTAssertEqual("100", result.cvc)
    }

    func test_toJson_ShouldReturnExpectedValue_withoutCvv() {
        let value = PaymentRequestPaymentMethod(id: "pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ")
        let json = value.toJson()
        guard let id = json["id"] as? String else {
            XCTFail("serialized JSON did not contain 'id'")
            return
        }
        XCTAssertNil(json["cvv"])
        XCTAssertEqual("pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ", id)
    }

    func test_toJson_ShouldReturnExpectedValue_withCvv() {
        let value = PaymentRequestPaymentMethod(id: "pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ", cvc: "100")
        let json = value.toJson()
        guard
            let id = json["id"] as? String,
            let cvv = json["cvc"] as? String else {
            XCTFail("serialized JSON did not contain 'id' and/or 'cvc'")
            return
        }
        XCTAssertEqual("100", cvv)
        XCTAssertEqual("pmt_01G0EYVFR02KBBVE2YWQ8AKMGJ", id)
    }
}
