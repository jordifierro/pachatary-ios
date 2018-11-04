import UIKit

class RootViewController: UIViewController {
    private var current: UIViewController
    private let authRepo = AuthDataDependencyInjector.authRepository

    var pendingExperienceIdDeeplink: String? = nil
    var pendingProfileUsernameDeeplink: String? = nil
    
    init() {
        if authRepo.hasPersonCredentials() {
            let mainViewController = UIStoryboard.init(name: "Main", bundle: nil)
                .instantiateInitialViewController()
            self.current = mainViewController!
        }
        else {
            let welcomeViewController = UIStoryboard.init(name: "Person", bundle: nil)
                .instantiateInitialViewController()
            self.current = welcomeViewController!
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParentViewController: self)
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParentViewController: nil)
        addChildViewController(new)
        
        transition(from: current, to: new, duration: 0.3,
                   options: [.transitionCrossDissolve, .curveEaseOut], animations: { })
            { completed in
                self.current.removeFromParentViewController()
                new.didMove(toParentViewController: self)
                self.current = new
                completion?()
            }
    }
    
    func navigateToMain() {
        let mainViewController = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateInitialViewController()!
        animateFadeTransition(to: mainViewController)
    }

    func navigateToProfileRouter(_ username: String) {
        let profileRouterViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "profileRouterViewController")
            as! ProfileRouterViewController
        profileRouterViewController.username = username
        animateFadeTransition(to: profileRouterViewController)
    }

    func navigateToProfile(_ username: String) {
        pendingProfileUsernameDeeplink = username
        navigateToMain()
    }

    func navigateToExperienceRouter(_ experienceShareId: String) {
        let experienceRouterViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "experienceRouterViewController")
            as! ExperienceRouterViewController
        experienceRouterViewController.experienceShareId = experienceShareId
        animateFadeTransition(to: experienceRouterViewController)
    }

    func navigateToExperience(_ experienceId: String) {
        pendingExperienceIdDeeplink = experienceId
        navigateToMain()
    }

    func navigateToLogin(token: String) {
        let loginViewController = UIStoryboard.init(name: "Person", bundle: nil)
            .instantiateViewController(withIdentifier: "loginViewController")
        (loginViewController as! LoginViewController).token = token
        animateFadeTransition(to: loginViewController)
    }

    func navigateToConfirmEmail(token: String) {
        let confirmEmailViewController = UIStoryboard.init(name: "Person", bundle: nil)
            .instantiateViewController(withIdentifier: "confirmEmailViewController")
        (confirmEmailViewController as! ConfirmEmailViewController).token = token
        animateFadeTransition(to: confirmEmailViewController)
    }
}
