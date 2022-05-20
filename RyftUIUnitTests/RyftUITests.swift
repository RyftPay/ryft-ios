import XCTest
import PassKit

@testable import RyftCore
@testable import RyftUI

final class RyftUITests: XCTestCase {

    func test_supportedNetworks_returnsExpectedValue() {
        let expected: [PKPaymentNetwork] = [.visa, .masterCard]
        XCTAssertEqual(expected, RyftUI.supportedNetworks)
    }

    func test_pkPaymentErrors_shouldReturnEmptyResult_whenGivenNil() {
        let result = RyftUI.pkPaymentErrors(nil)
        XCTAssertEqual(0, result.count)
    }

    func test_pkPaymentErrors_shouldReturnEmptyResult_whenGivenNonHttpError() {
        let result = RyftUI.pkPaymentErrors(NSError())
        XCTAssertEqual(0, result.count)
    }

    func test_pkPaymentErrors_shouldReturnEmptyResult_whenGivenPreRequestHttpError() {
        let error = HttpError.preRequest(message: "validation failed")
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(0, result.count)
    }

    func test_pkPaymentErrors_shouldReturnEmptyResult_whenGivenGeneralHttpError() {
        let error = HttpError.general(message: "oops!")
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(0, result.count)
    }

    func test_pkPaymentErrors_shouldReturnEmptyResult_whenGivenHttpErrorWithoutBillingError() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(code: "500", message: "uh oh")
        ])
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(0, result.count)
    }

    func test_pkPaymentErrors_shouldReturnExpectedError_whenBillingAddressLineOneIsInvalid() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.lineOne is invalid"
            )
        ])
        let expected = PKPaymentRequest.paymentBillingAddressInvalidError(
            withKey: CNPostalAddressStreetKey,
            localizedDescription: "billingAddress.lineOne is invalid"
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(expected, result[0] as NSError)
    }

    func test_pkPaymentErrors_shouldReturnExpectedError_whenBillingAddressCityIsInvalid() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.city is invalid"
            )
        ])
        let expected = PKPaymentRequest.paymentBillingAddressInvalidError(
            withKey: CNPostalAddressCityKey,
            localizedDescription: "billingAddress.city is invalid"
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(expected, result[0] as NSError)
    }

    func test_pkPaymentErrors_shouldReturnExpectedError_whenBillingAddressCountryIsInvalid() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.country is invalid"
            )
        ])
        let expected = PKPaymentRequest.paymentBillingAddressInvalidError(
            withKey: CNPostalAddressCountryKey,
            localizedDescription: "billingAddress.country is invalid"
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(expected, result[0] as NSError)
    }

    func test_pkPaymentErrors_shouldReturnExpectedError_whenBillingAddressPostalCodeIsInvalid() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.postalCode is invalid"
            )
        ])
        let expected = PKPaymentRequest.paymentBillingAddressInvalidError(
            withKey: CNPostalAddressPostalCodeKey,
            localizedDescription: "billingAddress.postalCode is invalid"
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(expected, result[0] as NSError)
    }

    func test_pkPaymentErrors_shouldReturnExpectedError_whenBillingAddressRegionIsInvalid() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.region is invalid"
            )
        ])
        let expected = PKPaymentRequest.paymentBillingAddressInvalidError(
            withKey: CNPostalAddressStateKey,
            localizedDescription: "billingAddress.region is invalid"
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(expected, result[0] as NSError)
    }

    func test_pkPaymentErrors_shouldReturnExpectedError_whenBillingAddressFirstNameIsInvalid() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.firstName is invalid"
            )
        ])
        let expected = NSError(
            domain: PKPaymentErrorDomain,
            code: PKPaymentError.billingContactInvalidError.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "billingAddress.firstName is invalid",
                PKPaymentErrorKey.contactFieldUserInfoKey.rawValue: PKContactField.name
            ]
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(expected, result[0] as NSError)
    }

    func test_pkPaymentErrors_shouldReturnExpectedError_whenBillingAddressLastNameIsInvalid() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.lastName is invalid"
            )
        ])
        let expected = NSError(
            domain: PKPaymentErrorDomain,
            code: PKPaymentError.billingContactInvalidError.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "billingAddress.lastName is invalid",
                PKPaymentErrorKey.contactFieldUserInfoKey.rawValue: PKContactField.name
            ]
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(expected, result[0] as NSError)
    }

    func test_pkPaymentErrors_shouldReturnMultipleErrors_whenBillingAddressHasMultipleErrors() {
        let error = badResponseError(errors: [
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.lastName is invalid"
            ),
            RyftApiError.RyftApiErrorElement(
                code: "400",
                message: "billingAddress.city is invalid"
            )
        ])
        let expectedNameError = NSError(
            domain: PKPaymentErrorDomain,
            code: PKPaymentError.billingContactInvalidError.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "billingAddress.lastName is invalid",
                PKPaymentErrorKey.contactFieldUserInfoKey.rawValue: PKContactField.name
            ]
        ) as NSError
        let expectedCityError = PKPaymentRequest.paymentBillingAddressInvalidError(
            withKey: CNPostalAddressCityKey,
            localizedDescription: "billingAddress.city is invalid"
        ) as NSError
        let result = RyftUI.pkPaymentErrors(error)
        XCTAssertEqual(2, result.count)
        XCTAssertEqual(expectedNameError, result[0] as NSError)
        XCTAssertEqual(expectedCityError, result[1] as NSError)
    }

    private func badResponseError(errors: [RyftApiError.RyftApiErrorElement]) -> HttpError {
        HttpError.badResponse(
            detail: HttpError.HttpErrorDetail(
                statusCode: 400,
                body: RyftApiError(
                    requestId: UUID().uuidString.lowercased(),
                    code: "some_code",
                    errors: errors
                )
            )
        )
    }
}
