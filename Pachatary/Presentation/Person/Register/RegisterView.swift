import UIKit

protocol RegisterView : class {
    func enableButton()
    func disableButton()
    func showSuccessMessage()
    func showLoader(_ visibility: Bool)
    func showError(message: String)
}

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var registerButton: GreenButton!
    
    var presenter: RegisterPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter =  PersonDependencyInjector.registerPresenter(view: self)

        self.navigationItem.title = "REGISTER"

        registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)

        emailTextField.layer.cornerRadius = 23
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        emailTextField.leftViewMode = .always
        emailTextField.delegate = self
        usernameTextField.layer.cornerRadius = 23
        usernameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        usernameTextField.leftViewMode = .always
        usernameTextField.delegate = self
    }

    @objc func register(_ sender: UIButton!) {
        self.view.endEditing(true)
        presenter!.registerClick(emailTextField.text!, usernameTextField.text!)
    }
}

extension RegisterViewController: RegisterView {

    func enableButton() {
        registerButton.isEnabled = true
    }

    func disableButton() {
        registerButton.isEnabled = false
    }

    func showSuccessMessage() {
        Snackbar.show("We've send a confirmation email to you, open it!", .long)
    }

    func showLoader(_ visibility: Bool) {
        if visibility { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }

    func showError(message: String) {
        Snackbar.show(message, .long)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
