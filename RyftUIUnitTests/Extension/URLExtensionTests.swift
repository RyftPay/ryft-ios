import XCTest

@testable import RyftUI

final class URLExtensionTests: XCTestCase {

    func test_queryParameters_shouldReturnEmptyResult_whenUrlHasNoItems() {
        let url = URL(string: "https://ryftpay.com")!
        XCTAssertEqual(url.queryParameters, [:])
    }

    func test_queryParameters_shouldReturnNonEmptyResult_whenUrlHasItems() {
        let url = URL(string: "https://ryftpay.com?a1=123&a2=456")!
        XCTAssertEqual(url.queryParameters, [
            "a1": "123",
            "a2": "456"
        ])
    }

    func test_paymentSessionIdFromQueryParams_shouldReturnNil_whenUrlDoesNotContainIt() {
        let url = URL(string: "https://ryftpay.com")!
        XCTAssertNil(url.paymentSessionIdFromQueryParams)
    }

    func test_paymentSessionIdFromQueryParams_shouldReturnValue_whenUrlDoesContainIt() {
        let url = URL(string: "https://ryftpay.com?ps=ps_123")!
        XCTAssertEqual(url.paymentSessionIdFromQueryParams, "ps_123")
    }
}
