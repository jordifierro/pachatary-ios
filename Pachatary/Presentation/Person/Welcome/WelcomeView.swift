import UIKit
import TTGSnackbar

protocol WelcomeView {
    func navigateToMain()
    func navigateToLogin()
    func enableButtons()
    func disableButtons()
    func showLoader(_ visibility: Bool)
    func showError()
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let presenter = PersonDependencyInjector.welcomePresenter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    
    @objc func start(_ sender: UIButton!) {
        presenter.onStartClick()
    }
    
    @objc func login(_ sender: UIButton!) {
        presenter.onLoginClick()
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
        let snackbar = TTGSnackbar(message: "Oops! Something went wrong. Please try again",
                                   duration: .middle)
        snackbar.show()
    }
}
