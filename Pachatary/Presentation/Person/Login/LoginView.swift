import UIKit
import RxSwift

protocol LoginView {
    func navigateToMain()
}

class LoginViewController: UIViewController {
    
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
}
