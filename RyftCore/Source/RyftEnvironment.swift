public enum RyftEnvironment {

    case sandbox
    case production

    public static func fromApiKey(publicKey: String) -> RyftEnvironment {
        if publicKey.starts(with: "pk_sandbox") {
            return .sandbox
        }
        return .production
    }
}
