import Foundation

public struct RyftThreeDsError: Error, Equatable {

    public enum ErrorType: String {
        case timeout
        case protocolError = "protocol_error"
        case runtimeError = "runtime_error"
    }

    public let type: ErrorType
    public let errorCode: String?
    public let errorComponent: String?
    public let errorDescription: String?
    public let errorDetail: String?

    init(
        type: ErrorType,
        errorCode: String? = nil,
        errorComponent: String? = nil,
        errorDescription: String? = nil,
        errorDetail: String? = nil
    ) {
        self.type = type
        self.errorCode = RyftThreeDsError.nilIfBlank(errorCode)
        self.errorComponent = RyftThreeDsError.nilIfBlank(errorComponent)
        self.errorDescription = RyftThreeDsError.nilIfBlank(errorDescription)
        self.errorDetail = RyftThreeDsError.nilIfBlank(errorDetail)
    }

    private static func nilIfBlank(_ value: String?) -> String? {
        guard let value = value,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }
}
