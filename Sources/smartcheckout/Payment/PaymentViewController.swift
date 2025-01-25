import UIKit
import WebKit

final class PaymentViewController: UIViewController {
    private static let webViewMessageName: String = "smartcheckout"
    
    private let sessionKey: String
    private let completion: (PaymentSheetResult) -> Void

    private let loadingView: UIActivityIndicatorView = {
        let ai: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            ai = UIActivityIndicatorView(style: .medium)
        } else {
            ai = UIActivityIndicatorView()
        }
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        ai.hidesWhenStopped = true
        return ai
    }()
    
    private lazy var webview: WKWebView = {
        let config = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            config.preferences.javaScriptEnabled = true
        }
        config.userContentController.add(self, name: Self.webViewMessageName)
        
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.navigationDelegate = self
        webview.insetsLayoutMarginsFromSafeArea = false
        if #available(iOS 15.0, *) {
            webview.underPageBackgroundColor = .white
        }
        
        return webview
    }()
    
    public init(sessionKey: String, completion: @escaping (PaymentSheetResult) -> Void) {
        self.sessionKey = sessionKey
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        
        presentationController?.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupWebview()
    }
    
    private func setupWebview() {
        if let url = URL(string: "https://pr-152.d160dk6e5tokn6.amplifyapp.com/inspira/checkout?sdk=1&partner_division=38-4&code=\(sessionKey)") {
            var urlRequest = URLRequest(url: url)
            urlRequest.timeoutInterval = 2
            view.backgroundColor = .white
            webview.load(urlRequest)
        } else {
            setError()
        }
    }
}

// MARK: - WKNavigationDelegate
extension PaymentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Content started loading
        stopLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Finished loading content
        stopLoading()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        // Generic error
        stopLoading()
        setError()
        completion(.failed(error))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        // URL Error
        stopLoading()
        setError()
        completion(.failed(error))
    }
}

// MARK: - WKScriptMessageHandler
extension PaymentViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Self.webViewMessageName {
            guard let body = message.body as? String else { return }
            switch body {
            case "success":
                completion(.success)
            case "cancel":
                completion(.canceled)
            case "error":
                completion(.failed(NSError(domain: "", code: 0)))
            default: break
            }
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension PaymentViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        // Call completion handler with cancel?
    }
}

// MARK: - Helpers
private extension PaymentViewController {
    func stopLoading() {
        loadingView.stopAnimating()
    }
    
    func setError() {
        view.backgroundColor = .red
    }
}

// MARK: - Layout
private extension PaymentViewController {
    func setupLayout() {
        view.addSubview(webview)
        webview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        webview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(loadingView)
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
