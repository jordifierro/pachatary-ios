import UIKit
import TTGSnackbar

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
        let snackbar = TTGSnackbar(message: "Oops! Something went wrong. Please try again",
                                   duration: .forever,
                                   actionText: "RETRY",
                                   actionBlock: { [weak self] snackbar in
                                    self?.presenter.retry()
                                    snackbar.dismiss()
        })
        snackbar.show()
    }

    func showLoading(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }
}
