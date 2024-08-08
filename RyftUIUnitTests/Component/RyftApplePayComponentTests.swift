import XCTest
import PassKit
import RyftCore

@testable import RyftUI

final class RyftApplePayComponentTests: XCTestCase {

    func test_present_shouldCompleteWithFailure_whenApiReturnsNoPaymentSession() {
        let apiClient = MockRyftApiClient()
        let component = createComponent(
            apiClient: apiClient,
            delegate: ApplePayComponentDelegateTester(),
            config: .auto(config: RyftApplePayConfig(
                merchantIdentifier: "id",
                merchantCountryCode: "GB",
                merchantName: "Ryft"
            ))
        )
        let expectation = expectation(description: "test")
        component?.present { presented in
            XCTAssertFalse(presented)
            XCTAssertTrue(apiClient.didCallGetPaymentSession)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10.0) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }

    func test_present_shouldCompleteWithSuccess_whenApiReturnsPaymentSession() {
        let delegate = ApplePayComponentDelegateTester()
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = TestFixtures.paymentSession()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            config: .auto(config: RyftApplePayConfig(
                merchantIdentifier: "id",
                merchantCountryCode: "GB",
                merchantName: "Ryft"
            ))
        )
        let expectation = expectation(description: "test")
        component?.present { presented in
            XCTAssertTrue(presented)
            XCTAssertTrue(apiClient.didCallGetPaymentSession)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15.0) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }

    func test_present_shouldNotCallApiClientToFetchPaymentSession_whenUsingManualConfig() {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "id"
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.supportedNetworks = [.visa, .masterCard]
        paymentRequest.countryCode = "GB"
        paymentRequest.currencyCode = "GBP"
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: 150)
        ]
        let delegate = ApplePayComponentDelegateTester()
        let apiClient = MockRyftApiClient()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            config: .manual(paymentRequest: paymentRequest)
        )
        let expectation = expectation(description: "test")
        component?.present { _ in
            XCTAssertFalse(apiClient.didCallGetPaymentSession)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10.0) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }

    private func createComponent(
        apiClient: RyftApiClient,
        delegate: RyftApplePayComponentDelegate,
        config: RyftApplePayComponent.RyftApplePayComponentConfig
    ) -> RyftApplePayComponent? {
        RyftApplePayComponent(
            clientSecret: "ps_01FCTS1XMKH9FF43CAFA4CXT3P_secret_b83f2653-06d7-44a9-a548-5825e8186004",
            accountId: nil,
            config: config,
            delegate: delegate,
            apiClient: apiClient
        )
    }
}
