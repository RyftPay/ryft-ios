import XCTest
import Ravelin3DS

@testable import RyftUI

final class RyftThreeDsErrorTests: XCTestCase {

    func test_init_shouldDefaultDetailsToNil() {
        let error = RyftThreeDsError(type: .timeout)

        XCTAssertEqual(error.type, .timeout)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorComponent)
        XCTAssertNil(error.errorDescription)
        XCTAssertNil(error.errorDetail)
    }

    func test_init_shouldReturnNilDetails_whenDetailsAreBlank() {
        let error = RyftThreeDsError(
            type: .protocolError,
            errorCode: "",
            errorComponent: " ",
            errorDescription: "\n",
            errorDetail: ""
        )

        XCTAssertEqual(error, RyftThreeDsError(type: .protocolError))
    }

    func test_from_shouldReturnProtocolErrorDetails_whenGivenProtocolErrorEvent() {
        let error = RyftThreeDsError.from(protocolErrorEvent: protocolErrorEvent(
            errorCode: "201",
            errorComponent: "C",
            errorDescription: "Required element missing",
            errorDetail: "oobContinueLabel"
        ))

        XCTAssertEqual(error.type, .protocolError)
        XCTAssertEqual(error.errorCode, "201")
        XCTAssertEqual(error.errorComponent, "C")
        XCTAssertEqual(error.errorDescription, "Required element missing")
        XCTAssertEqual(error.errorDetail, "oobContinueLabel")
    }

    func test_from_shouldReturnNilDetails_whenProtocolErrorEventDetailsAreBlank() {
        let error = RyftThreeDsError.from(protocolErrorEvent: protocolErrorEvent(
            errorCode: "203",
            errorComponent: "",
            errorDescription: "",
            errorDetail: ""
        ))

        XCTAssertEqual(error, RyftThreeDsError(type: .protocolError, errorCode: "203"))
    }

    func test_from_shouldReturnRuntimeErrorDetails_whenGivenRuntimeErrorEvent() {
        let error = RyftThreeDsError.from(
            runtimeErrorEvent: Ravelin3DS.RuntimeErrorEvent("5001", "Timed Out")
        )

        XCTAssertEqual(error.type, .runtimeError)
        XCTAssertEqual(error.errorCode, "5001")
        XCTAssertEqual(error.errorDescription, "Timed Out")
        XCTAssertNil(error.errorComponent)
        XCTAssertNil(error.errorDetail)
    }

    func test_from_shouldReturnNilErrorCode_whenRuntimeErrorEventHasNoCode() {
        let error = RyftThreeDsError.from(
            runtimeErrorEvent: Ravelin3DS.RuntimeErrorEvent(nil, "Timed Out")
        )

        XCTAssertEqual(error, RyftThreeDsError(type: .runtimeError, errorDescription: "Timed Out"))
    }

    func test_from_shouldReturnSameError_whenChallengeErrorIsThreeDsError() {
        let threeDsError = RyftThreeDsError(type: .protocolError, errorCode: "201")

        XCTAssertEqual(RyftThreeDsError.from(challengeError: threeDsError), threeDsError)
    }

    func test_from_shouldReturnRuntimeErrorWithDescription_whenChallengeErrorIsNotThreeDsError() {
        let error = RyftThreeDsError.from(challengeError: RavelinThreeDsError.missingTransaction)

        XCTAssertEqual(error, RyftThreeDsError(type: .runtimeError, errorDescription: "missingTransaction"))
    }

    private func protocolErrorEvent(
        errorCode: String,
        errorComponent: String,
        errorDescription: String,
        errorDetail: String
    ) -> Ravelin3DS.ProtocolErrorEvent {
        Ravelin3DS.ProtocolErrorEvent(
            "sdk-transaction-id",
            Ravelin3DS.ErrorMessage(
                transactionID: "transaction-id",
                errorCode: errorCode,
                errorComponent: errorComponent,
                errorDescription: errorDescription,
                errorDetail: errorDetail,
                errorMessageType: "CRes",
                messageVersionNumber: "2.2.0"
            )
        )
    }
}
