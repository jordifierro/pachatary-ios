import UIKit
import RxSwift

protocol LoginView {
    func navigateToMain()
    func showLoader(_ visibility: Bool)
    func showRetry()
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
        AppDelegate.shared.rootViewController.navigateToMain()
    }

    func showLoader(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }

    func showRetry() {
        Snackbar.showErrorWithRetry { [unowned self] () in self.presenter.retry() }
    }
}
