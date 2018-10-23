import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    enum WebViewType {
        case privacyPolicy
        case termsAndConditions
    }

    var webView: WKWebView!
    var webViewType: WebViewType?

    override func loadView() {
        super.loadView()

        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var urlString = AppDataDependencyInjector.apiUrl
        switch self.webViewType! {
        case .privacyPolicy:
            urlString += "/privacy-policy"
            self.navigationItem.title = "PRIVACY POLICY"
        case .termsAndConditions:
            urlString += "/terms-and-conditions"
            self.navigationItem.title = "TERMS AND CONDITIONS"
        }
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
}

