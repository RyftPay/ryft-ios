import Foundation

public protocol HttpClient {

    typealias HttpResponseHandler<T: Decodable> = (Result<T, HttpError>) -> Void

    func postBody<ResponseBody>(
        url: URL,
        headers: [String: String],
        body: [String: Any],
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    )

    func makeRequest<ResponseBody>(
        url: URL,
        headers: [String: String],
        method: HttpMethod,
        responseType: ResponseBody.Type,
        completion: @escaping HttpResponseHandler<ResponseBody>
    )
}
