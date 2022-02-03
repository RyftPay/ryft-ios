import Foundation

public struct RyftApiError: Codable {

    public let requestId: String
    public let code: String
    public let errors: [RyftApiErrorElement]

    enum CodingKeys: String, CodingKey {
        case requestId
        case code
        case errors
    }

    public struct RyftApiErrorElement: Codable {

        public let code: String
        public let message: String

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
