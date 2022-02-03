import Foundation

public final class RyftHttpClient: HttpClient {

    public static let shared = RyftHttpClient(
        urlSession: URLSession(configuration: URLSessionConfiguration.default)
    )

    private let urlSession: URLSession

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    public func postBody<ResponseBody>(
        url: URL,
        headers: [String: String],
        body: [String: Any],
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    ) where ResponseBody: Decodable {
        var urlRequest = buildUrlRequest(url: url, headers: headers, httpMethod: .post)
        do {
            urlRequest.httpBody = try JSONSerialization.data(
                withJSONObject: body,
                options: .prettyPrinted
            )
        } catch {
            completion(.failure(.preRequest(message: error.localizedDescription)))
            return
        }
        urlSession.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.general(message: error.localizedDescription)))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.general(message: "non-http response")))
                return
            }
            guard let data = data else {
                completion(.failure(.general(message: "response had no data")))
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseBody = try decoder.decode(responseType, from: data)
                completion(.success(responseBody))
            } catch {
                let errorBody = try? decoder.decode(RyftApiError.self, from: data)
                completion(.failure(.badResponse(
                    detail: HttpError.HttpErrorDetail(
                        statusCode: response.statusCode,
                        body: errorBody ?? RyftApiError.unknown
                    )
                )))
            }
        }.resume()
    }

    public func makeRequest<ResponseBody>(
        url: URL,
        headers: [String: String],
        method: HttpMethod,
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    ) where ResponseBody: Decodable {
        let requestUrl = buildUrlRequest(url: url, headers: headers, httpMethod: method)
        urlSession.dataTask(with: requestUrl) { data, response, error in
            if let error = error {
                completion(.failure(.general(message: error.localizedDescription)))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.general(message: "non-http response")))
                return
            }
            guard let data = data else {
                completion(.failure(.general(message: "response had no data")))
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseBody = try decoder.decode(responseType, from: data)
                completion(.success(responseBody))
            } catch {
                let errorBody = try? decoder.decode(RyftApiError.self, from: data)
                completion(.failure(.badResponse(
                    detail: HttpError.HttpErrorDetail(
                        statusCode: response.statusCode,
                        body: errorBody ?? RyftApiError.unknown
                    )
                )))
            }
        }.resume()
    }

    private func buildUrlRequest(
        url: URL,
        headers: [String: String],
        httpMethod: HttpMethod
    ) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }
}
