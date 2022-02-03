import UIKit
import WebKit

protocol RyftThreeDSecureWebDelegate: AnyObject {
    func onThreeDsCompleted(
        paymentSessionId: String,
        queryParams: [String: String]
    )
}

final class RyftThreeDSecureViewController: UIViewController, WKNavigationDelegate {

    private var webView: WKWebView!
    private let returnUrl: URL
    private let authUrl: URL
    private weak var delegate: RyftThreeDSecureWebDelegate?

    init(returnUrl: URL, authUrl: URL, delegate: RyftThreeDSecureWebDelegate) {
        self.returnUrl = returnUrl
        self.authUrl = authUrl
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: authUrl)
        webView.navigationDelegate = self
        webView.load(request)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let dismissed = navigationAction.request.url.map { url in
            let result = shouldDismiss(url: url)
            if result {
                dismissOnReturnUrl(absoluteUrl: url)
            }
            return result
        } ?? false
        decisionHandler(dismissed ? .cancel : .allow)
    }

    private func shouldDismiss(url: URL) -> Bool {
        return url.host == returnUrl.host && url.paymentSessionIdFromQueryParams != nil
    }

    private func dismissOnReturnUrl(absoluteUrl: URL) {
        dismiss(animated: true) {
            self.delegate?.onThreeDsCompleted(
                paymentSessionId: absoluteUrl.paymentSessionIdFromQueryParams ?? "",
                queryParams: absoluteUrl.queryParameters
            )
        }
    }
}
