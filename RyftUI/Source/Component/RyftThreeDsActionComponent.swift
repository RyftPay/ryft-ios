import RyftCore
import Checkout3DS

public protocol RyftThreeDsActionHandler {

    func handle(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Error?) -> Void
    )
}

public final class DefaultRyftThreeDsActionHandler: RyftThreeDsActionHandler {

    private let threeDsSdk: Checkout3DSService

    init(threeDsSdk: Checkout3DSService) {
        self.threeDsSdk = threeDsSdk
    }

    init(environment: RyftEnvironment) {
        self.threeDsSdk = DefaultRyftThreeDsActionHandler.initialiseThreeDsService(
            environment: environment
        )
    }

    public func handle(
        action: RequiredActionIdentifyApp,
        completion: @escaping (Error?) -> Void
    ) {
        let params = AuthenticationParameters(
            sessionID: action.sessionId,
            sessionSecret: action.sessionSecret,
            scheme: action.scheme
        )
        DispatchQueue.main.async {
            self.threeDsSdk.authenticate(authenticationParameters: params, completion: { result in
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            })
        }
    }

    private static func initialiseThreeDsService(environment: RyftEnvironment) -> Checkout3DSService {
        var env = Environment.sandbox
        if environment == .production {
            env = Environment.production
        }
        return Checkout3DSService(
            environment: env,
            locale: Locale(identifier: "en_GB"),
            uiCustomization: DefaultUICustomization(
                toolbarCustomization: DefaultToolbarCustomization(),
                labelCustomization: DefaultLabelCustomization(),
                entrySelectionCustomization: DefaultEntrySelectionCustomization(),
                buttonCustomizations: DefaultButtonCustomizations(),
                footerCustomization: DefaultFooterCustomization(
                    backgroundColor: .clear,
                    font: .systemFont(ofSize: 0),
                    textColor: .clear,
                    labelFont: .italicSystemFont(ofSize: 0),
                    labelTextColor: .clear,
                    expandIndicatorColor: .clear
               ),
                whitelistCustomization: DefaultWhitelistCustomization()
            ),
            appURL: nil
        )
    }
}
