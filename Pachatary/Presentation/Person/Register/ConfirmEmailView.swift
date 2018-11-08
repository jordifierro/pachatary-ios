import UIKit
import RxSwift

protocol ConfirmEmailView : class {
    func navigateToMain()
    func showLoader(_ visibility: Bool)
    func showRetry()
    func showSuccess()
    func showError()
}

class ConfirmEmailViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var presenter: ConfirmEmailPresenter?
    var token: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = PersonDependencyInjector.confirmEmailPresenter(view: self,
                                                                   confirmationToken: token)
        presenter!.create()
    }
}

extension ConfirmEmailViewController: ConfirmEmailView {

    func navigateToMain() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            AppDelegate.shared.rootViewController.navigateToMain()
        }
    }

    func showLoader(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }

    func showRetry() {
        Snackbar.showErrorWithRetry { [unowned self] () in self.presenter!.retry() }
    }

    func showSuccess() {
        Snackbar.show("Email successfully confirmed!".localized(), .long)
    }

    func showError() {
        Snackbar.show("Wrong confirmation token. Please, ask a new one".localized(), .long)
    }
}
