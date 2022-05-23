import XCTest
import PassKit

@testable import RyftCore

final class PaymentRequestCustomerDetailsTests: XCTestCase {

    func test_init_shouldReturnExpectedValue() {
        let result = PaymentRequestCustomerDetails(email: "support@ryftpay.com")
        XCTAssertEqual("support@ryftpay.com", result.email)
    }

    func test_init_fromPKContact_shouldReturnNil_whenContactIsNil() {
        XCTAssertNil(PaymentRequestCustomerDetails(pkContact: nil))
    }

    func test_init_fromPKContact_shouldReturnNil_whenEmailAddressIsMissing() {
        let contact = PKContact()
        XCTAssertNil(PaymentRequestCustomerDetails(pkContact: contact))
    }

    func test_init_fromPKContact_shouldReturnValue_whenEmailAddressIsPresent() {
        let contact = PKContact()
        contact.emailAddress = "support@ryftpay.com"
        let expected = PaymentRequestCustomerDetails(email: "support@ryftpay.com")
        XCTAssertEqual(expected, PaymentRequestCustomerDetails(pkContact: contact))
    }

    func test_toJson_shouldReturnExpectedValue() {
        let details = PaymentRequestCustomerDetails(email: "support@ryftpay.com")
        let result = details.toJson()
        guard let email = result["email"] as? String else {
            XCTFail("serialized JSON country email was not expected type")
            return
        }
        XCTAssertEqual("support@ryftpay.com", email)
    }
}
