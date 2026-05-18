import RyftCore

public protocol RyftThreeDsActionHandler {

    func handle(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Error?) -> Void
    )
}

public final class DefaultRyftThreeDsActionHandler: RyftThreeDsActionHandler {

    private let environment: RyftEnvironment

    public init(environment: RyftEnvironment) {
        self.environment = environment
    }

    public func handle(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Error?) -> Void
    ) {
        // Ravelin 3DS implementation — coming in next step
        completion(nil)
    }
}
