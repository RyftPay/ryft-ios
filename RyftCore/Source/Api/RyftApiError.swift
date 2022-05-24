import Foundation

public struct RyftApiError: Codable {

    public let requestId: String
    public let code: String
    public let errors: [RyftApiErrorElement]

    public init(
        requestId: String,
        code: String,
        errors: [RyftApiErrorElement]
    ) {
        self.requestId = requestId
        self.code = code
        self.errors = errors
    }

    enum CodingKeys: String, CodingKey {
        case requestId
        case code
        case errors
    }

    public struct RyftApiErrorElement: Codable {

        public let code: String
        public let message: String

        public init(code: String, message: String) {
            self.code = code
            self.message = message
        }

        enum CodingKeys: String, CodingKey {
            case code
            case message
        }
    }

    public static let unknown = RyftApiError(
        requestId: UUID().uuidString.lowercased(),
        code: "500",
        errors: []
    )
}
