import XCTest

@testable import RyftCore

final class ContinuePaymentRequestTest: XCTestCase {

    private let params = ThreeDsTransactionParams(
        sdkTransactionId: "sdk_txn_123",
        sdkApplicationId: "sdk_app_123",
        sdkEncryptedData: "sdk_enc_data",
        sdkEphemeralPublicKey: "sdk_epk_123",
        sdkReferenceNumber: "sdk_ref_123"
    )

    func test_from_shouldReturnExpectedClientSecret() {
        let result = ContinuePaymentRequest.from(clientSecret: "secret", params: params)
        XCTAssertEqual("secret", result.clientSecret)
    }

    func test_from_toJson_shouldReturnExpectedTopLevelKeys() {
        let result = ContinuePaymentRequest.from(clientSecret: "secret", params: params).toJson()
        XCTAssertNotNil(result["clientSecret"])
        XCTAssertNotNil(result["threeDs"])
    }

    func test_from_toJson_shouldReturnExpectedAppAuthentication() {
        let result = ContinuePaymentRequest.from(clientSecret: "secret", params: params).toJson()
        guard let threeDs = result["threeDs"] as? [String: Any] else {
            XCTFail("serialized JSON threeDs field was not expected type")
            return
        }
        XCTAssertNil(threeDs["challengeResult"])
        guard let appAuthentication = threeDs["appAuthentication"] as? [String: Any] else {
            XCTFail("serialized JSON appAuthentication field was not expected type")
            return
        }
        guard
            let sdkTransId = appAuthentication["sdkTransId"] as? String,
            let sdkAppId = appAuthentication["sdkAppId"] as? String,
            let sdkEncData = appAuthentication["sdkEncData"] as? String,
            let sdkEphemeralPublicKey = appAuthentication["sdkEphemeralPublicKey"] as? String,
            let sdkReferenceNumber = appAuthentication["sdkReferenceNumber"] as? String,
            let sdkMaxTimeoutInMinutes = appAuthentication["sdkMaxTimeoutInMinutes"] as? Int
        else {
            XCTFail("serialized JSON appAuthentication did not contain the expected fields")
            return
        }
        XCTAssertEqual(params.sdkTransactionId, sdkTransId)
        XCTAssertEqual(params.sdkApplicationId, sdkAppId)
        XCTAssertEqual(params.sdkEncryptedData, sdkEncData)
        XCTAssertEqual(params.sdkEphemeralPublicKey, sdkEphemeralPublicKey)
        XCTAssertEqual(params.sdkReferenceNumber, sdkReferenceNumber)
        XCTAssertEqual(10, sdkMaxTimeoutInMinutes)
    }

    func test_from_toJson_shouldReturnExpectedDeviceRenderOptions() {
        let result = ContinuePaymentRequest.from(clientSecret: "secret", params: params).toJson()
        guard
            let threeDs = result["threeDs"] as? [String: Any],
            let appAuthentication = threeDs["appAuthentication"] as? [String: Any],
            let deviceRenderOptions = appAuthentication["deviceRenderOptions"] as? [String: Any]
        else {
            XCTFail("serialized JSON deviceRenderOptions field was not expected type")
            return
        }
        guard
            let sdkInterface = deviceRenderOptions["sdkInterface"] as? String,
            let sdkUiTypes = deviceRenderOptions["sdkUiTypes"] as? [String]
        else {
            XCTFail("serialized JSON deviceRenderOptions did not contain the expected fields")
            return
        }
        XCTAssertEqual("01", sdkInterface)
        XCTAssertEqual(["01", "02", "03"], sdkUiTypes)
    }

    func test_fromChallengeResult_toJson_shouldReturnExpectedTopLevelKeys() {
        let result = ContinuePaymentRequest.fromChallengeResult(
            clientSecret: "secret",
            transactionStatus: "Y",
            threeDSServerTransactionId: "3ds_txn_123"
        ).toJson()
        XCTAssertNotNil(result["clientSecret"])
        XCTAssertNotNil(result["threeDs"])
    }

    func test_fromChallengeResult_toJson_shouldReturnBase64EncodedChallengeResult() {
        let result = ContinuePaymentRequest.fromChallengeResult(
            clientSecret: "secret",
            transactionStatus: "Y",
            threeDSServerTransactionId: "3ds_txn_123"
        ).toJson()
        guard let threeDs = result["threeDs"] as? [String: Any] else {
            XCTFail("serialized JSON threeDs field was not expected type")
            return
        }
        XCTAssertNil(threeDs["appAuthentication"])
        guard let challengeResult = threeDs["challengeResult"] as? String else {
            XCTFail("serialized JSON challengeResult field was not expected type")
            return
        }
        guard let decoded = Data(base64Encoded: challengeResult),
              let json = try? JSONSerialization.jsonObject(with: decoded) as? [String: String]
        else {
            XCTFail("challengeResult was not valid base64-encoded JSON")
            return
        }
        XCTAssertEqual("Y", json["transStatus"])
        XCTAssertEqual("3ds_txn_123", json["threeDSServerTransID"])
    }
}
