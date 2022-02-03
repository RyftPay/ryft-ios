import XCTest

@testable import RyftCore

class EndpointTest: XCTestCase {

    private let baseApiUrl = "https://dummy-api.ryftpay.com/v1"

    func test_paymentSessions_shouldReturnExpectedValue() {
        guard let url = Endpoint.paymentSessions(baseUrl: baseApiUrl) else {
            XCTFail("expected non-nil endpoint")
            return
        }
        XCTAssertEqual("https://dummy-api.ryftpay.com/v1/payment-sessions", url.absoluteString)
    }

    func test_attemptPayment_shouldReturnExpectedValue() {
        guard let url = Endpoint.attemptPayment(baseUrl: baseApiUrl) else {
            XCTFail("expected non-nil endpoint")
            return
        }
        XCTAssertEqual(
            "https://dummy-api.ryftpay.com/v1/payment-sessions/attempt-payment",
            url.absoluteString
        )
    }

    func test_paymentSessionId_shouldReturnExpectedValue() {
        guard let url = Endpoint.paymentSessionId(
            baseUrl: baseApiUrl,
            id: "ps_123",
            clientSecret: "_secret_"
        ) else {
            XCTFail("expected non-nil endpoint")
            return
        }
        XCTAssertEqual(
            "https://dummy-api.ryftpay.com/v1/payment-sessions/ps_123?clientSecret=_secret_",
            url.absoluteString
        )
    }

    func test_determineApiBaseUrl_shouldReturnSandboxWhenGivenSandboxKey() {
        XCTAssertEqual(
            Endpoint.sandboxApiUrl,
            Endpoint.determineApiBaseUrl(from: "pk_sandbox_123")
        )
    }

    func test_determineApiBaseUrl_shouldReturnSandboxWhenGivenProductionKey() {
        XCTAssertEqual(
            Endpoint.productionApiUrl,
            Endpoint.determineApiBaseUrl(from: "pk_123")
        )
    }
}
