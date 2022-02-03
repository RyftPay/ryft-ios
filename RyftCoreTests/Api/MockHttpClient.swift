import Foundation

@testable import RyftCore

class MockHttpClient: HttpClient {

    var shouldFailWithError = false
    var responseBody: Decodable?
    var url: URL?
    var headers: [String: String] = [:]
    var httpMethod: HttpMethod?

    func postBody<ResponseBody>(
        url: URL,
        headers: [String: String],
        body: [String: Any],
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    ) where ResponseBody: Decodable {
        self.url = url
        self.headers = headers
        self.httpMethod = .post
        if shouldFailWithError {
            completion(.failure(.general(message: "uh oh")))
            return
        }
        guard let responseBody = responseBody as? ResponseBody else {
            completion(.failure(.badResponse(detail: HttpError.HttpErrorDetail(
                statusCode: 500,
                body: RyftApiError(
                    requestId: UUID().uuidString.lowercased(),
                    code: "500",
                    errors: []
                )
            ))))
            return
        }
        completion(.success(responseBody))
    }

    func makeRequest<ResponseBody>(
        url: URL,
        headers: [String: String],
        method: HttpMethod,
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    ) where ResponseBody: Decodable {
        self.url = url
        self.headers = headers
        self.httpMethod = method
        if shouldFailWithError {
            completion(.failure(.general(message: "uh oh")))
            return
        }
        guard let responseBody = responseBody as? ResponseBody else {
            completion(.failure(.badResponse(detail: HttpError.HttpErrorDetail(
                statusCode: 500,
                body: RyftApiError(
                    requestId: UUID().uuidString.lowercased(),
                    code: "500",
                    errors: []
                )
            ))))
            return
        }
        completion(.success(responseBody))
    }
}
