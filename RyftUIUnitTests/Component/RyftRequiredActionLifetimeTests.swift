import XCTest
import UIKit

@testable import RyftCore
@testable import RyftUI

final class RyftRequiredActionLifetimeTests: XCTestCase {

    private let presenter = UIViewController()
    private let challengeSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
    private let failedSession = TestFixtures.paymentSession(lastError: .threeDSecureAuthenticationFailure)

    func test_handle_shouldReportChallengeFailure_whenComponentIsReleasedInChallengeFailedCallback() {
        let threeDsHandler = DeferredChallengeHandler()
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [.success(challengeSession), .success(failedSession)]
        let delegate = RyftRequiredActionDelegateTester()
        var component: RyftRequiredActionComponent? = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )
        delegate.onChallengeFailed = { component = nil }
        component?.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        threeDsHandler.completeChallenge(.failed(error: RyftThreeDsError(type: .timeout)))

        XCTAssertEqual(apiClient.continuePaymentRequests.count, 2)
        XCTAssertTrue(threeDsHandler.cleanupInvoked)
    }

    func test_handle_shouldCleanUpAndReleaseComponent_whenReleasedBeforeChallengeFailureReportCompletes() {
        let threeDsHandler = DeferredChallengeHandler()
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [.success(challengeSession), .success(failedSession)]
        apiClient.deferContinuePaymentFromRequest = 2
        let delegate = RyftRequiredActionDelegateTester()
        var component: RyftRequiredActionComponent? = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )
        weak var releasedComponent = component
        delegate.onChallengeFailed = { component = nil }
        component?.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        threeDsHandler.completeChallenge(.failed(error: RyftThreeDsError(type: .timeout)))

        XCTAssertEqual(apiClient.continuePaymentRequests.count, 2)
        XCTAssertFalse(threeDsHandler.cleanupInvoked)
        apiClient.completeDeferredContinuePayments()
        XCTAssertTrue(threeDsHandler.cleanupInvoked)
        XCTAssertNil(releasedComponent)
    }

    func test_handle_shouldCleanUp_whenComponentOwningTheApiClientIsReleasedInChallengeFailedCallback() {
        let threeDsHandler = DeferredChallengeHandler()
        let httpClient = StubHttpClient(responses: [challengeSession, failedSession])
        httpClient.deferFromRequest = 2
        let delegate = RyftRequiredActionDelegateTester()
        var component: RyftRequiredActionComponent? = createComponent(
            apiClient: DefaultRyftApiClient(
                baseApiUrl: "https://example.com",
                publicApiKey: "pk_sandbox_123",
                httpClient: httpClient
            ),
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )
        delegate.onChallengeFailed = { component = nil }
        let challengeStarted = expectation(description: "challenge started")
        threeDsHandler.onChallengeStarted = { challengeStarted.fulfill() }
        component?.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)
        wait(for: [challengeStarted], timeout: 2)

        threeDsHandler.completeChallenge(.failed(error: RyftThreeDsError(type: .timeout)))
        let cleanedUp = expectation(description: "3DS handler cleaned up")
        threeDsHandler.onCleanup = { cleanedUp.fulfill() }
        httpClient.completeDeferredRequests()

        wait(for: [cleanedUp], timeout: 2)
        XCTAssertEqual(httpClient.requestCount, 2)
    }

    private func createComponent(
        apiClient: RyftApiClient,
        delegate: RyftRequiredActionDelegate,
        threeDsActionHandler: RyftThreeDsActionHandler
    ) -> RyftRequiredActionComponent {
        let component = RyftRequiredActionComponent(
            config: RyftRequiredActionComponent.Configuration(clientSecret: "secret"),
            apiClient: apiClient,
            threeDsActionHandler: threeDsActionHandler,
            sessionCheckInterval: 0
        )
        component.delegate = delegate
        return component
    }
}

private final class DeferredChallengeHandler: RyftThreeDsActionHandler {

    var onChallengeStarted: (() -> Void)?
    var onCleanup: (() -> Void)?
    private var challengeCompletion: ((ThreeDsChallengeResult) -> Void)?
    private(set) var cleanupInvoked = false

    func createTransaction(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Result<ThreeDsTransactionParams, Error>) -> Void
    ) {
        completion(.success(TestFixtures.threeDsTransactionParams()))
    }

    func doChallenge(
        action: ChallengeAction,
        presentingViewController: UIViewController,
        completion: @escaping (ThreeDsChallengeResult) -> Void
    ) {
        challengeCompletion = completion
        onChallengeStarted?()
    }

    func completeChallenge(_ result: ThreeDsChallengeResult) {
        challengeCompletion?(result)
    }

    func cleanup() {
        cleanupInvoked = true
        onCleanup?()
    }
}

private final class StubHttpClient: HttpClient {

    var deferFromRequest: Int?
    private(set) var requestCount = 0
    private var responses: [PaymentSession]
    private var deferredRequests: [() -> Void] = []

    init(responses: [PaymentSession]) {
        self.responses = responses
    }

    func postBody<ResponseBody>(
        url: URL,
        headers: [String: String],
        body: [String: Any],
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    ) where ResponseBody: Decodable {
        requestCount += 1
        guard !responses.isEmpty, let response = responses.removeFirst() as? ResponseBody else {
            completion(.failure(.general(message: "no stubbed response")))
            return
        }
        if let firstDeferred = deferFromRequest, requestCount >= firstDeferred {
            deferredRequests.append { completion(.success(response)) }
            return
        }
        completion(.success(response))
    }

    func makeRequest<ResponseBody>(
        url: URL,
        headers: [String: String],
        method: HttpMethod,
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    ) where ResponseBody: Decodable {
        completion(.failure(.general(message: "no stubbed response")))
    }

    func completeDeferredRequests() {
        let requests = deferredRequests
        deferredRequests = []
        requests.forEach { $0() }
    }
}
