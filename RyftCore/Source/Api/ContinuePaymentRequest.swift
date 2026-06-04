import Foundation

public struct ContinuePaymentRequest {

    let clientSecret: String
    let threeDs: ThreeDsDetails

    struct ThreeDsDetails {
        let appAuthentication: AppAuthentication?
        let challengeResult: ThreeDsChallengeResult?

        func toJson() -> [String: Any] {
            var json: [String: Any] = [:]
            if let auth = appAuthentication {
                json["appAuthentication"] = auth.toJson()
            }
            if let result = challengeResult {
                json["challengeResult"] = result.toBase64EncodedJson()
            }
            return json
        }
    }

    struct ThreeDsChallengeResult {
        let transStatus: String
        let threeDSServerTransactionId: String

        func toBase64EncodedJson() -> String {
            let json: [String: Any] = [
                "transStatus": transStatus,
                "threeDSServerTransID": threeDSServerTransactionId
            ]
            let data = (try? JSONSerialization.data(withJSONObject: json)) ?? Data()
            return data.base64EncodedString()
        }
    }

    struct AppAuthentication {
        let sdkAppId: String
        let sdkEncData: String
        let sdkEphemeralPublicKey: String
        let sdkMaxTimeoutInMinutes: Int
        let sdkReferenceNumber: String
        let sdkTransId: String
        let deviceRenderOptions: DeviceRenderOptions

        func toJson() -> [String: Any] {
            [
                "sdkAppId": sdkAppId,
                "sdkEncData": sdkEncData,
                "sdkEphemeralPublicKey": sdkEphemeralPublicKey,
                "sdkMaxTimeoutInMinutes": sdkMaxTimeoutInMinutes,
                "sdkReferenceNumber": sdkReferenceNumber,
                "sdkTransId": sdkTransId,
                "deviceRenderOptions": deviceRenderOptions.toJson()
            ]
        }
    }

    struct DeviceRenderOptions {
        let sdkInterface: String
        let sdkUiTypes: [String]

        func toJson() -> [String: Any] {
            [
                "sdkInterface": sdkInterface,
                "sdkUiTypes": sdkUiTypes
            ]
        }
    }

    func toJson() -> [String: Any] {
        [
            "clientSecret": clientSecret,
            "threeDs": threeDs.toJson()
        ]
    }

    private static let sdkMaxTimeoutMinutes = 10
    private static let sdkInterface = "01"
    private static let sdkUiTypes = ["01", "02", "03", "04"]

    public static func from(
        clientSecret: String,
        params: ThreeDsTransactionParams
    ) -> ContinuePaymentRequest {
        ContinuePaymentRequest(
            clientSecret: clientSecret,
            threeDs: ThreeDsDetails(
                appAuthentication: AppAuthentication(
                    sdkAppId: params.sdkApplicationId,
                    sdkEncData: params.sdkEncryptedData,
                    sdkEphemeralPublicKey: params.sdkEphemeralPublicKey,
                    sdkMaxTimeoutInMinutes: sdkMaxTimeoutMinutes,
                    sdkReferenceNumber: params.sdkReferenceNumber,
                    sdkTransId: params.sdkTransactionId,
                    deviceRenderOptions: DeviceRenderOptions(
                        sdkInterface: sdkInterface,
                        sdkUiTypes: sdkUiTypes
                    )
                ),
                challengeResult: nil
            )
        )
    }

    public static func fromChallengeResult(
        clientSecret: String,
        transactionStatus: String,
        threeDSServerTransactionId: String
    ) -> ContinuePaymentRequest {
        ContinuePaymentRequest(
            clientSecret: clientSecret,
            threeDs: ThreeDsDetails(
                appAuthentication: nil,
                challengeResult: ThreeDsChallengeResult(
                    transStatus: transactionStatus,
                    threeDSServerTransactionId: threeDSServerTransactionId
                )
            )
        )
    }
}
