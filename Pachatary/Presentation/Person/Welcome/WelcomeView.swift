import UIKit

protocol WelcomeView {
    func navigateToMain()
    func navigateToLogin()
    func enableButtons()
    func disableButtons()
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
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
        AppDelegate.shared.rootViewController.navigateToAskLoginEmail()
    }
    
    func enableButtons() {
        startButton.isEnabled = true
        loginButton.isEnabled = true
    }
    
    func disableButtons() {
        startButton.isEnabled = false
        loginButton.isEnabled = false
    }
}
