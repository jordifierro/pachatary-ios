import UIKit
import TTGSnackbar

protocol ExperienceRouterView : class {
    func navigateToExperience(_ experienceId: String)
    func showRetry()
    func showLoading(_ visibility: Bool)
}

class ExperienceRouterViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var presenter: ExperienceRouterPresenter!
    var experienceShareId: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ExperienceDependencyInjector.experienceRouterPresenter(
            view: self, experienceShareId: experienceShareId)

        presenter.create()
    }

    deinit {
        self.presenter.destroy()
    }
}

extension ExperienceRouterViewController: ExperienceRouterView {
    func navigateToExperience(_ experienceId: String) {
        AppDelegate.shared.rootViewController.navigateToExperience(experienceId)
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
