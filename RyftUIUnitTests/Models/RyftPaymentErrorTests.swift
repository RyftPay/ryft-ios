import XCTest
import RyftCore

@testable import RyftUI

final class RyftPaymentErrorTests: XCTestCase {

    private let unknownDisplayError = RyftPaymentError(paymentSessionError: .unknown).displayError

    func test_init_shouldDefaultErrorCodeAndMessageToNil() {
        let error = RyftPaymentError(paymentSessionError: .insufficientFunds)

        XCTAssertEqual(error.paymentSessionError, .insufficientFunds)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorMessage)
        XCTAssertNil(error.threeDsError)
    }

    func test_init_shouldUseLocalizedCvvMessage_whenErrorIsCvv2Failure() {
        let error = RyftPaymentError(paymentSessionError: .cvv2Failure)

        XCTAssertNotEqual(error.displayError, unknownDisplayError)
        XCTAssertTrue(error.displayError.contains("CVC"))
    }

    func test_from_shouldReturnApiErrorCodeAndMessage_whenBadResponseHasErrors() {
        let error = RyftPaymentError.from(error: badResponse(
            RyftApiError.RyftApiErrorElement(code: "bad_request", message: "The request was invalid")
        ))

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertEqual(error.displayError, unknownDisplayError)
        XCTAssertEqual(error.errorCode, "bad_request")
        XCTAssertEqual(error.errorMessage, "The request was invalid")
    }

    func test_from_shouldReturnNilErrorMessage_whenBadResponseMessageIsBlank() {
        let error = RyftPaymentError.from(error: badResponse(
            RyftApiError.RyftApiErrorElement(code: "bad_request", message: " ")
        ))

        XCTAssertEqual(error.errorCode, "bad_request")
        XCTAssertNil(error.errorMessage)
    }

    func test_from_shouldReturnNilErrorCode_whenBadResponseCodeIsBlank() {
        let error = RyftPaymentError.from(error: badResponse(
            RyftApiError.RyftApiErrorElement(code: " ", message: "The request was invalid")
        ))

        XCTAssertNil(error.errorCode)
        XCTAssertEqual(error.errorMessage, "The request was invalid")
    }

    func test_from_shouldReturnNilCodeAndMessage_whenBadResponseHasNoErrors() {
        let error = RyftPaymentError.from(error: badResponse())

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertEqual(error.displayError, unknownDisplayError)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorMessage)
    }

    func test_from_shouldReturnErrorMessage_whenHttpErrorIsGeneral() {
        let error = RyftPaymentError.from(error: HttpError.general(message: "timeout"))

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertEqual(error.errorMessage, "timeout")
    }

    func test_from_shouldReturnErrorMessage_whenHttpErrorIsPreRequest() {
        let error = RyftPaymentError.from(error: HttpError.preRequest(message: "invalid request"))

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertEqual(error.errorMessage, "invalid request")
    }

    func test_from_shouldReturnErrorDescription_whenErrorIsNotHttpError() {
        let error = RyftPaymentError.from(error: RyftRequiredActionError.missingIdentifyDetails)

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertEqual(error.errorMessage, "missingIdentifyDetails")
        XCTAssertNil(error.threeDsError)
    }

    func test_from_shouldReturnThreeDsErrorWithoutErrorCode_whenErrorIsThreeDsError() {
        let threeDsError = RyftThreeDsError(
            type: .protocolError,
            errorCode: "201",
            errorComponent: "C",
            errorDescription: "Required element missing",
            errorDetail: "oobContinueLabel"
        )

        let error = RyftPaymentError.from(error: threeDsError)

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertEqual(error.displayError, unknownDisplayError)
        XCTAssertNil(error.errorCode)
        XCTAssertEqual(error.errorMessage, "Required element missing")
        XCTAssertEqual(error.threeDsError, threeDsError)
        XCTAssertEqual(error.threeDsError?.errorCode, "201")
    }

    func test_from_shouldReturnThreeDsErrorType_whenThreeDsErrorHasNoDescription() {
        let error = RyftPaymentError.from(error: RyftThreeDsError(type: .timeout))

        XCTAssertNil(error.errorCode)
        XCTAssertEqual(error.errorMessage, "timeout")
        XCTAssertEqual(error.threeDsError, RyftThreeDsError(type: .timeout))
    }

    func test_from_shouldKeepPaymentSessionError_whenGiven() {
        let error = RyftPaymentError.from(
            error: RyftThreeDsError(type: .timeout),
            paymentSessionError: .threeDSecureAuthenticationFailure
        )

        XCTAssertEqual(error.paymentSessionError, .threeDSecureAuthenticationFailure)
        XCTAssertNotEqual(error.displayError, unknownDisplayError)
        XCTAssertEqual(error.threeDsError, RyftThreeDsError(type: .timeout))
    }

    func test_from_shouldReturnNilDetails_whenErrorIsNilAndPaymentSessionErrorIsGiven() {
        let error = RyftPaymentError.from(error: nil, paymentSessionError: .insufficientFunds)

        XCTAssertEqual(error.paymentSessionError, .insufficientFunds)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorMessage)
        XCTAssertNil(error.threeDsError)
    }

    func test_from_shouldReturnNilCodeAndMessage_whenErrorIsNil() {
        let error = RyftPaymentError.from(error: nil)

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorMessage)
    }

    private func badResponse(_ errors: RyftApiError.RyftApiErrorElement...) -> HttpError {
        .badResponse(detail: HttpError.HttpErrorDetail(
            statusCode: 400,
            body: RyftApiError(requestId: "req_123", code: "400", errors: errors)
        ))
    }
}
