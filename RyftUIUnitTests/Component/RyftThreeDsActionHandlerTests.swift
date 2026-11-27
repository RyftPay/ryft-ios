import XCTest
import UIKit
import RyftCore

@testable import RyftUI

final class RyftThreeDsActionHandlerTests: XCTestCase {

    private let productionDirectoryServerIds = [
        "visa": "A000000003",
        "mastercard": "A000000004",
        "amex": "A000000025",
        "discover": "A000000152",
        "jcb": "A000000065",
        "unionpay": "A000000333"
    ]

    func test_toDirectoryServerId_shouldReturnMockDirectoryServer_whenSandbox() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .sandbox)

        for scheme in productionDirectoryServerIds.keys {
            XCTAssertEqual("M000000003", try handler.toDirectoryServerId(scheme: scheme))
        }
    }

    func test_toDirectoryServerId_shouldReturnMockDirectoryServer_whenSandboxAndSchemeUnsupported() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .sandbox)

        XCTAssertEqual("M000000003", try handler.toDirectoryServerId(scheme: "diners"))
    }

    func test_toDirectoryServerId_shouldReturnSchemeDirectoryServer_whenProduction() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .production)

        for (scheme, expected) in productionDirectoryServerIds {
            XCTAssertEqual(expected, try handler.toDirectoryServerId(scheme: scheme))
        }
    }

    func test_toDirectoryServerId_shouldIgnoreSchemeCasing_whenProduction() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .production)

        XCTAssertEqual("A000000003", try handler.toDirectoryServerId(scheme: "VISA"))
        XCTAssertEqual("A000000004", try handler.toDirectoryServerId(scheme: "MasterCard"))
    }

    func test_toDirectoryServerId_shouldThrowUnsupportedScheme_whenProductionAndSchemeUnsupported() {
        let handler = DefaultRyftThreeDsActionHandler(environment: .production)

        XCTAssertThrowsError(try handler.toDirectoryServerId(scheme: "diners")) { error in
            guard case RavelinThreeDsError.unsupportedScheme(let scheme) = error else {
                XCTFail("expected unsupportedScheme but got \(error)")
                return
            }
            XCTAssertEqual("diners", scheme)
        }
    }

    func test_createTransaction_shouldCompleteWithFailure_whenRavelinPublicKeyIsEmpty() {
        let handler = DefaultRyftThreeDsActionHandler(environment: .sandbox)
        let completed = expectation(description: "completion called")

        handler.createTransaction(
            action: RequiredActionIdentifyApp(
                ravelinPublicKey: "",
                protocolVersion: "2.2.0",
                scheme: "visa",
                paymentMethodId: "pmt_123"
            )
        ) { result in
            if case .success = result {
                XCTFail("expected failure but got \(result)")
            }
            completed.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func test_doChallenge_shouldCompleteWithRuntimeError_whenTransactionIsMissing() {
        let handler = DefaultRyftThreeDsActionHandler(environment: .sandbox)
        let completed = expectation(description: "completion called")

        handler.doChallenge(
            action: TestFixtures.challengeAction(),
            presentingViewController: UIViewController()
        ) { result in
            guard case .failed(let error) = result else {
                XCTFail("expected .failed but got \(result)")
                return
            }
            XCTAssertEqual(
                error as? RyftThreeDsError,
                RyftThreeDsError(type: .runtimeError, errorDescription: "missingTransaction")
            )
            completed.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func test_toRequestorAppUrl_shouldReturnNil_whenThreeDSRequestorAppUrlIsNotConfigured() {
        let handler = DefaultRyftThreeDsActionHandler(environment: .sandbox)

        XCTAssertNil(handler.toRequestorAppUrl(sdkTransactionId: "sdk-transaction-id"))
    }

    func test_toRequestorAppUrl_shouldAppendSdkTransactionId_whenThreeDSRequestorAppUrlIsConfigured() {
        let handler = DefaultRyftThreeDsActionHandler(
            environment: .sandbox,
            threeDSRequestorAppUrl: URL(string: "https://merchant.com/3ds-return")
        )

        XCTAssertEqual(
            "https://merchant.com/3ds-return?transID=sdk-transaction-id",
            handler.toRequestorAppUrl(sdkTransactionId: "sdk-transaction-id")
        )
    }

    func test_toRequestorAppUrl_shouldKeepExistingQuery_whenThreeDSRequestorAppUrlHasQuery() {
        let handler = DefaultRyftThreeDsActionHandler(
            environment: .sandbox,
            threeDSRequestorAppUrl: URL(string: "https://merchant.com/3ds-return?source=bank")
        )

        XCTAssertEqual(
            "https://merchant.com/3ds-return?source=bank&transID=sdk-transaction-id",
            handler.toRequestorAppUrl(sdkTransactionId: "sdk-transaction-id")
        )
    }

    func test_toRequestorAppUrl_shouldReturnNil_whenSdkTransactionIdIsMissing() {
        let handler = DefaultRyftThreeDsActionHandler(
            environment: .sandbox,
            threeDSRequestorAppUrl: URL(string: "https://merchant.com/3ds-return")
        )

        XCTAssertNil(handler.toRequestorAppUrl(sdkTransactionId: nil))
    }
}
