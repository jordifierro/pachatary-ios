import UIKit

class RootViewController: UIViewController {
    private var current: UIViewController
    private let authRepo = AuthDataDependencyInjector.authRepository

    var pendingExperienceIdDeeplink: String? = nil
    var pendingProfileUsernameDeeplink: String? = nil
    var pendingAskLoginEmailDeeplink = false
    
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
    
    private func animateFadeTransition(to new: UIViewController,
                                       duration: Float = 0.3,
                                       completion: (() -> Void)? = nil) {
        current.willMove(toParentViewController: nil)
        addChildViewController(new)
        
        transition(from: current, to: new, duration: TimeInterval(duration),
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
        animateFadeTransition(to: profileRouterViewController, duration: 0.0)
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
        animateFadeTransition(to: experienceRouterViewController, duration: 0.0)
    }

    func navigateToExperience(_ experienceId: String) {
        pendingExperienceIdDeeplink = experienceId
        navigateToMain()
    }

    func navigateToLogin(token: String) {
        let loginViewController = UIStoryboard.init(name: "Person", bundle: nil)
            .instantiateViewController(withIdentifier: "loginViewController")
        (loginViewController as! LoginViewController).token = token
        animateFadeTransition(to: loginViewController, duration: 0.0)
    }

    func navigateToConfirmEmail(token: String) {
        let confirmEmailViewController = UIStoryboard.init(name: "Person", bundle: nil)
            .instantiateViewController(withIdentifier: "confirmEmailViewController")
        (confirmEmailViewController as! ConfirmEmailViewController).token = token
        animateFadeTransition(to: confirmEmailViewController, duration: 0.0)
    }

    func navigateToAskLoginEmail() {
        let welcomeViewController = UIStoryboard.init(name: "Person", bundle: nil)
            .instantiateInitialViewController()
        pendingAskLoginEmailDeeplink = true
        animateFadeTransition(to: welcomeViewController!)
    }
}
