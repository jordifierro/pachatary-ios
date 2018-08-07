import UIKit

class RootViewController: UIViewController {
    private var current: UIViewController
    private let authRepo = AuthDataDependencyInjector.authRepository
    
    init() {
        if authRepo.hasPersonCredentials() {
            let mainViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
            self.current = mainViewController!
        }
        else {
            let welcomeViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcomeViewController")
            self.current = welcomeViewController
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
}

