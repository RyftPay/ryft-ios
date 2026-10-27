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

    func test_from_shouldReturnNilCodeAndMessage_whenBadResponseHasNoErrors() {
        let error = RyftPaymentError.from(error: badResponse())

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertEqual(error.displayError, unknownDisplayError)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorMessage)
    }

    func test_from_shouldReturnNilCodeAndMessage_whenHttpErrorIsNotBadResponse() {
        let error = RyftPaymentError.from(error: HttpError.general(message: "timeout"))

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorMessage)
    }

    func test_from_shouldReturnNilCodeAndMessage_whenErrorIsNotHttpError() {
        let error = RyftPaymentError.from(error: RyftRequiredActionError.missingIdentifyDetails)

        XCTAssertEqual(error.paymentSessionError, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.errorMessage)
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
