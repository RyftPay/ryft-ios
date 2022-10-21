import Foundation

public final class DefaultRyftApiClient: RyftApiClient {

    private let baseApiUrl: String
    private let publicApiKey: String
    private let httpClient: HttpClient

    init(
        baseApiUrl: String,
        publicApiKey: String,
        httpClient: HttpClient
    ) {
        DefaultRyftApiClient.validateApiKey(publicApiKey)
        self.baseApiUrl = baseApiUrl
        self.publicApiKey = publicApiKey
        self.httpClient = httpClient
        self.environment = .fromApiKey(publicKey: publicApiKey)
    }

    public var environment: RyftEnvironment = .sandbox

    public convenience init(
        publicApiKey: String
    ) {
        self.init(
            baseApiUrl: Endpoint.determineApiBaseUrl(from: publicApiKey),
            publicApiKey: publicApiKey,
            httpClient: RyftHttpClient.shared
        )
    }

    public func attemptPayment(
        request: AttemptPaymentRequest,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        guard let url = Endpoint.attemptPayment(baseUrl: baseApiUrl) else {
            return
        }
        httpClient.postBody(
            url: url,
            headers: requestHeaders(accountId),
            body: request.toJson(),
            responseType: PaymentSession.self,
            completion: { completion($0) }
        )
    }

    public func getPaymentSession(
        id: String,
        clientSecret: String,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        guard let url = Endpoint.paymentSessionId(
            baseUrl: baseApiUrl,
            id: id,
            clientSecret: clientSecret
        ) else {
            return
        }
        httpClient.makeRequest(
            url: url,
            headers: requestHeaders(accountId),
            method: .get,
            responseType: PaymentSession.self,
            completion: completion
        )
    }

    private func requestHeaders(_ accountId: String?) -> [String: String] {
        var defaultHeaders = [
            "Authorization": publicApiKey,
            "User-Agent": Constants.userAgent,
            "Content-Type": "application/json"
        ]
        if let accountId = accountId {
            defaultHeaders["Account"] = accountId
        }
        return defaultHeaders
    }

    private static func validateApiKey(_ apiKey: String) {
        if apiKey.starts(with: "sk_") {
            assertionFailure(
                "You are using a secret API key! Please use your public API key instead!"
            )
        }
        if !apiKey.starts(with: "pk_") {
            assertionFailure(
                "The API key you have provided does not appear correct, please check you are using your public API key."
            )
        }
    }
}
