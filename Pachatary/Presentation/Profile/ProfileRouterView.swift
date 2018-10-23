import UIKit

protocol ProfileRouterView : class {
    func navigateToProfile(_ username: String)
    func showRetry()
    func showLoading(_ visibility: Bool)
}

class ProfileRouterViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var username: String!
    var presenter: ProfileRouterPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ProfileDependencyInjector.profileRouterPresenter(view: self, username: username)

        presenter.create()
    }

    deinit {
        self.presenter.destroy()
    }
}

extension ProfileRouterViewController: ProfileRouterView {
    func navigateToProfile(_ username: String) {
        AppDelegate.shared.rootViewController.navigateToProfile(username)
    }

    func showRetry() {
        Snackbar.showErrorWithRetry({ [weak self] () in self?.presenter.retry() })
    }

    func showLoading(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }
}
