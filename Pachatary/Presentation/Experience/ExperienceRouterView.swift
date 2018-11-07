import UIKit

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
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            AppDelegate.shared.rootViewController.navigateToExperience(experienceId)
        }
    }

    func showRetry() {
        Snackbar.showErrorWithRetry({ [weak self] () in self?.presenter.retry() })
    }

    func showLoading(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }
}
