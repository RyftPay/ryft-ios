public enum HttpError: Error {

    case preRequest(message: String)
    case general(message: String)
    case badResponse(detail: HttpErrorDetail)

    public struct HttpErrorDetail {
        public let statusCode: Int
        public let body: RyftApiError

        public init(statusCode: Int, body: RyftApiError) {
            self.statusCode = statusCode
            self.body = body
        }
    }
}
