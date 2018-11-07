import UIKit
import RxSwift

protocol LoginView {
    func navigateToMain()
    func showLoader(_ visibility: Bool)
    func showRetry()
    func showError()
    func navigateToAskLoginEmail()
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var token: String!
    let presenter = PersonDependencyInjector.loginPresenter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        presenter.token = token
        presenter.create()
    }
}

extension LoginViewController: LoginView {
    
    func navigateToMain() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            AppDelegate.shared.rootViewController.navigateToMain()
        }
    }

    func navigateToAskLoginEmail() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            AppDelegate.shared.rootViewController.navigateToAskLoginEmail()
        }
    }

    func showLoader(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }

    func showRetry() {
        Snackbar.showErrorWithRetry { [unowned self] () in self.presenter.retry() }
    }

    func showError() {
        Snackbar.show("Oops! Some error occurred during login. Please, ask a new login email", .long)
    }
}
