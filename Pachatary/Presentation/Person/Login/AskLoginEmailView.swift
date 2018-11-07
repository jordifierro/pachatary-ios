import UIKit

protocol AskLoginEmailView {
    func enableButton()
    func disableButton()
    func showSuccessMessage()
    func showLoader(_ visibility: Bool)
    func showError()
    func showEmptyEmailError()
}

class AskLoginEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let presenter = PersonDependencyInjector.askLoginEmailPresenter
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "LOGIN"
        
        askButton.addTarget(self, action: #selector(ask), for: .touchUpInside)

        emailTextField.layer.cornerRadius = 23
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        emailTextField.leftView = paddingView
        emailTextField.leftViewMode = .always
        emailTextField.delegate = self

        presenter.view = self
    }
    
    @objc func ask(_ sender: UIButton!) {
        self.view.endEditing(true)
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
    
    func showSuccessMessage() {
        Snackbar.show("We've send an email to you, open it!", .long)
    }

    func showLoader(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }

    func showError() {
        Snackbar.showError()
    }

    func showEmptyEmailError() {
        Snackbar.show("Introduce your email", .short)
    }
}

extension AskLoginEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
