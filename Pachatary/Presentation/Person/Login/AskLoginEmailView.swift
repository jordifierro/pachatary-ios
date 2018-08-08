import UIKit

protocol AskLoginEmailView {
    func enableButton()
    func disableButton()
    func finishApp()
}

class AskLoginEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var askButton: UIButton!
    
    let presenter = PersonDependencyInjector.askLoginEmailPresenter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        askButton.addTarget(self, action: #selector(ask), for: .touchUpInside)
        
        presenter.view = self
    }
    
    @objc func ask(_ sender: UIButton!) {
        presenter.onAskClick(emailTextField.text!)
    }
}

extension AskLoginEmailViewController: AskLoginEmailView {
    
    func enableButton() {
        askButton.isEnabled = true
    }
    
    func disableButton() {
        askButton.isEnabled = false
    }
    
    func finishApp() {
        exit(0) //TODO - Remove this, app should not be closed.
    }
}

