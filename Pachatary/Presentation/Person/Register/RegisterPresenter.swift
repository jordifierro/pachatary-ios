import Swift
import RxSwift

class RegisterPresenter {

    var authRepository: AuthRepository!
    var mainScheduler: ImmediateSchedulerType!
    unowned let view: RegisterView
    let disposeBag = DisposeBag()

    init(_ authRepository: AuthRepository, _ mainScheduler: ImmediateSchedulerType,
         _ view: RegisterView) {
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
        self.view = view
    }

    func registerClick(_ email: String, _ username: String) {
        if email.count == 0 { view.showError(message: "Email cannot be empty") }
        else if username.count == 0 { view.showError(message: "Username cannot be empty") }
        else {
            authRepository.register(email, username)
                .observeOn(mainScheduler)
                .subscribe { [unowned self] event in
                    switch event {
                    case .next(let result):
                        switch result.status {
                        case .success:
                            self.view.showSuccessMessage()
                            self.view.enableButton()
                            self.view.showLoader(false)
                        case .error:
                            self.view.enableButton()
                            self.view.showLoader(false)
                            switch result.error! {
                            case .clientException(_, _, let errorMessage):
                                self.view.showError(message: errorMessage)
                            default:
                                self.view.showError(message: "Oops! Some error occurred. Try again")
                            }
                        case .inProgress:
                            self.view.disableButton()
                            self.view.showLoader(true)
                        }
                    case .error(let error):
                        fatalError(error.localizedDescription)
                    case .completed: break
                    }
                }
                .disposed(by: disposeBag)
        }
    }
}
