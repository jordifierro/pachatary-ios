import UIKit

protocol WelcomeView {
    func navigateToMain()
    func navigateToLogin()
    func navigateToPrivacyPolicy()
    func navigateToTermsAndConditions()
    func enableButtons()
    func disableButtons()
    func showLoader(_ visibility: Bool)
    func showError()
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    @IBOutlet weak var privacyPolicyLabel: UILabel!

    let presenter = PersonDependencyInjector.welcomePresenter
    var webViewType: WebViewController.WebViewType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        let privacyPolicyTap = UITapGestureRecognizer(target: self, action: #selector(WelcomeViewController.privacyPolicyTap(sender:)))
        privacyPolicyLabel.isUserInteractionEnabled = true
        privacyPolicyLabel.addGestureRecognizer(privacyPolicyTap)
        let termsAndConditionsTap = UITapGestureRecognizer(target: self, action: #selector(WelcomeViewController.termsAndConditionsTap(sender:)))
        termsAndConditionsLabel.isUserInteractionEnabled = true
        termsAndConditionsLabel.addGestureRecognizer(termsAndConditionsTap)

        if AppDelegate.shared.rootViewController.pendingAskLoginEmailDeeplink {
            AppDelegate.shared.rootViewController.pendingAskLoginEmailDeeplink = false
            self.navigateToLogin()
        }
    }

    @objc func start(_ sender: UIButton!) {
        presenter.onStartClick()
    }
    
    @objc func login(_ sender: UIButton!) {
        presenter.onLoginClick()
    }

    @objc func privacyPolicyTap(sender: UITapGestureRecognizer) {
        presenter.onPrivacyPolicyClick()
    }

    @objc func termsAndConditionsTap(sender: UITapGestureRecognizer) {
        presenter.onTermsAndConditionsClick()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            if let destinationVC = segue.destination as? WebViewController {
                destinationVC.webViewType = self.webViewType
            }
        }
    }
}

extension WelcomeViewController: WelcomeView {

    func navigateToMain() {
        AppDelegate.shared.rootViewController.navigateToMain()
    }
    
    func navigateToLogin() {
        performSegue(withIdentifier: "askLoginEmailSegue", sender: self)
    }
    
    func enableButtons() {
        startButton.isEnabled = true
        loginButton.isEnabled = true
    }
    
    func disableButtons() {
        startButton.isEnabled = false
        loginButton.isEnabled = false
    }

    func showLoader(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }

    func showError() {
        Snackbar.showError()
    }

    func navigateToPrivacyPolicy() {
        self.webViewType = .privacyPolicy
        performSegue(withIdentifier: "webViewSegue", sender: self)
    }

    func navigateToTermsAndConditions() {
        self.webViewType = .termsAndConditions
        performSegue(withIdentifier: "webViewSegue", sender: self)
    }
}
