import Foundation

struct Endpoint {

    static let sandboxApiUrl = "https://sandbox-api.ryftpay.com/v1"
    static let productionApiUrl = "https://api.ryftpay.com/v1"

    static func paymentSessions(baseUrl: String) -> URL? {
        return URL(string: "\(baseUrl)/payment-sessions")
    }

    static func attemptPayment(baseUrl: String) -> URL? {
        return paymentSessions(baseUrl: baseUrl)?
            .appendingPathComponent("attempt-payment")
    }

    static func paymentSessionId(
        baseUrl: String,
        id: String,
        clientSecret: String
    ) -> URL? {
        guard let urlWithPath = paymentSessions(baseUrl: baseUrl)?
                .appendingPathComponent(id) else {
            return nil
        }
        guard var urlComponents = URLComponents(
                url: urlWithPath,
                resolvingAgainstBaseURL: true
        ) else {
            return urlWithPath
        }
        urlComponents.queryItems = [URLQueryItem(name: "clientSecret", value: clientSecret)]
        return urlComponents.url
    }

    static func determineApiBaseUrl(from publicKey: String) -> String {
        if publicKey.starts(with: "pk_sandbox") {
            return Endpoint.sandboxApiUrl
        }
        return Endpoint.productionApiUrl
    }
}
