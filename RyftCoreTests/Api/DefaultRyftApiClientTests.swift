import XCTest

@testable import RyftCore

class DefaultRyftApiClientTests: XCTestCase {

    private let baseUrl = "https://dummy-api.ryftpay.com"
    private let publicApiKey = "pk_sandbox_123"
    private let subAccountId = "ac_3fe8398f-8cdb-43a3-9be2-806c4f84c327"
    private var httpClient = MockHttpClient()

    override func setUp() {
        super.setUp()
        httpClient = MockHttpClient()
    }

    private func createApiClient() -> RyftApiClient {
        return DefaultRyftApiClient(
            baseApiUrl: baseUrl,
            publicApiKey: publicApiKey,
            httpClient: httpClient
        )
    }

    func test_attemptPayment_shouldReturnError_whenHttpClientReturnsNoResult() {
        let apiClient = createApiClient()
        httpClient.shouldFailWithError = true
        apiClient.attemptPayment(
            request: attemptPaymentRequest(),
            accountId: nil,
            completion: { result in
                switch result {
                case .success:
                    XCTFail("expected failure, but got success")
                case .failure(let httpError):
                    self.assertGeneralHttpError(httpError)
                }
            })
    }

    func test_attemptPayment_shouldReturnError_whenHttpClientMakesRequestButHasUnexpectedResponse() {
        let apiClient = createApiClient()
        apiClient.attemptPayment(
            request: attemptPaymentRequest(),
            accountId: nil,
            completion: { result in
                switch result {
                case .success:
                    XCTFail("expected failure, but got success")
                case .failure(let httpError):
                    self.assertResponseHttpError(httpError)
                }
            })
    }

    func test_attemptPayment_shouldUseExpectedHeaders_whenInvokingHttpClient_forNonSubAccountRequest() {
        let apiClient = createApiClient()
        let responseBody = TestFixtures.paymentSession()
        httpClient.responseBody = responseBody
        apiClient.attemptPayment(request: attemptPaymentRequest(), accountId: nil) { result in
            switch result {
            case .success:
                let expectedHeaders = [
                    "Authorization": self.publicApiKey,
                    "User-Agent": Constants.userAgent,
                    "Content-Type": "application/json"
                ]
                XCTAssertEqual(expectedHeaders, self.httpClient.headers)
            case .failure(let httpError):
                self.assertResponseHttpError(httpError)
            }
        }
    }

    func test_attemptPayment_shouldUseExpectedHeaders_whenInvokingHttpClient_forSubAccountRequest() {
        let apiClient = createApiClient()
        let responseBody = TestFixtures.paymentSession()
        httpClient.responseBody = responseBody
        apiClient.attemptPayment(request: attemptPaymentRequest(), accountId: subAccountId) { result in
            switch result {
            case .success:
                let expectedHeaders = [
                    "Authorization": self.publicApiKey,
                    "User-Agent": Constants.userAgent,
                    "Content-Type": "application/json",
                    "Account": self.subAccountId
                ]
                XCTAssertEqual(expectedHeaders, self.httpClient.headers)
            case .failure(let httpError):
                self.assertResponseHttpError(httpError)
            }
        }
    }

    func test_attemptPayment_shouldReturnExpectedResponse_whenSuccessful() {
        let apiClient = createApiClient()
        let responseBody = TestFixtures.paymentSession()
        httpClient.responseBody = responseBody
        apiClient.attemptPayment(request: attemptPaymentRequest(), accountId: subAccountId) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.id == responseBody.id)
            case .failure(let httpError):
                self.assertResponseHttpError(httpError)
            }
        }
    }

    func test_getPaymentSession_shouldReturnError_whenHttpClientReturnsNoResult() {
        let apiClient = createApiClient()
        httpClient.shouldFailWithError = true
        apiClient.getPaymentSession(
            id: "ps_123",
            clientSecret: "_secret_",
            accountId: nil,
            completion: { result in
                switch result {
                case .success:
                    XCTFail("expected failure, but got success")
                case .failure(let httpError):
                    self.assertGeneralHttpError(httpError)
                }
            })
    }

    func test_getPaymentSession_shouldReturnError_whenHttpClientMakesRequestButHasUnexpectedResponse() {
        let apiClient = createApiClient()
        apiClient.getPaymentSession(
            id: "ps_123",
            clientSecret: "_secret_",
            accountId: nil,
            completion: { result in
                switch result {
                case .success:
                    XCTFail("expected failure, but got success")
                case .failure(let httpError):
                    self.assertResponseHttpError(httpError)
                }
            })
    }

    func test_getPaymentSession_shouldUseExpectedHeaders_whenInvokingHttpClient_forNonSubAccountRequest() {
        let apiClient = createApiClient()
        let responseBody = TestFixtures.paymentSession()
        httpClient.responseBody = responseBody
        apiClient.getPaymentSession(
            id: "ps_123",
            clientSecret: "_secret_",
            accountId: nil
        ) { result in
            switch result {
            case .success:
                let expectedHeaders = [
                    "Authorization": self.publicApiKey,
                    "User-Agent": Constants.userAgent,
                    "Content-Type": "application/json"
                ]
                XCTAssertEqual(expectedHeaders, self.httpClient.headers)
            case .failure(let httpError):
                self.assertResponseHttpError(httpError)
            }
        }
    }

    func test_getPaymentSession_shouldUseExpectedHeaders_whenInvokingHttpClient_forSubAccountRequest() {
        let apiClient = createApiClient()
        let responseBody = TestFixtures.paymentSession()
        httpClient.responseBody = responseBody
        apiClient.getPaymentSession(
            id: "ps_123",
            clientSecret: "_secret_",
            accountId: subAccountId
        ) { result in
            switch result {
            case .success:
                let expectedHeaders = [
                    "Authorization": self.publicApiKey,
                    "User-Agent": Constants.userAgent,
                    "Content-Type": "application/json",
                    "Account": self.subAccountId
                ]
                XCTAssertEqual(expectedHeaders, self.httpClient.headers)
            case .failure(let httpError):
                self.assertResponseHttpError(httpError)
            }
        }
    }

    func test_getPaymentSession_shouldReturnExpectedResponse_whenSuccessful() {
        let apiClient = createApiClient()
        let responseBody = TestFixtures.paymentSession()
        httpClient.responseBody = responseBody
        apiClient.getPaymentSession(
            id: "ps_123",
            clientSecret: "_secret_",
            accountId: subAccountId
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.id == responseBody.id)
            case .failure(let httpError):
                self.assertResponseHttpError(httpError)
            }
        }
    }

    private func attemptPaymentRequest() -> AttemptPaymentRequest {
        return AttemptPaymentRequest.fromCard(
            clientSecret: "secret",
            number: "4242424242424242",
            expiryMonth: "10",
            expiryYear: "2028",
            cvc: "100",
            store: false
        )
    }

    private func assertGeneralHttpError(
        _ error: HttpError
    ) {
        guard case .general = error else {
            XCTFail("expected .general HttpError")
            return
        }
    }

    private func assertResponseHttpError(
        _ error: HttpError
    ) {
        guard case .badResponse = error else {
            XCTFail("expected .responseError HttpError")
            return
        }
    }
}
