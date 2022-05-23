import XCTest

@testable import RyftCore
@testable import RyftUI

final class RyftApplePayComponentTests: XCTestCase {

    func test_present_shouldCompleteWithFailure_whenApiReturnsNoPaymentSession() {
        let component = createComponent(
            apiClient: MockRyftApiClient(),
            delegate: ApplePayComponentDelegateTester()
        )
        let expectation = expectation(description: "test")
        component?.present { presented in
            XCTAssertFalse(presented)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }

    func test_present_shouldCompleteWithSuccess_whenApiReturnsPaymentSession() {
        let delegate = ApplePayComponentDelegateTester()
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = TestFixtures.paymentSession()
        let component = createComponent(apiClient: apiClient, delegate: delegate)
        let expectation = expectation(description: "test")
        component?.present { presented in
            XCTAssertTrue(presented)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }

    private func createComponent(
        apiClient: RyftApiClient,
        delegate: RyftApplePayComponentDelegate
    ) -> RyftApplePayComponent? {
        RyftApplePayComponent(
            clientSecret: "secret",
            accountId: nil,
            config: RyftApplePayConfig(
                merchantIdentifier: "id",
                merchantCountryCode: "GB",
                merchantName: "Ryft"
            ),
            apiClient: apiClient,
            delegate: delegate
        )
    }
}
