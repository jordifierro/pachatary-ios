import Swift
import RxSwift

class ConfirmEmailPresenter {

    var authRepository: AuthRepository!
    var mainScheduler: ImmediateSchedulerType!
    unowned let view: ConfirmEmailView
    let confirmationToken: String
    let disposeBag = DisposeBag()

    init(_ authRepository: AuthRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: ConfirmEmailView,
         _ confirmationToken: String) {
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
        self.view = view
        self.confirmationToken = confirmationToken
    }

    func create() {
        confirmEmail()
    }

    func retry() {
        confirmEmail()
    }

    private func confirmEmail() {
        authRepository.confirmEmail(confirmationToken)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showSuccess()
                        self.view.navigateToMain()
                    case .error:
                        self.view.showLoader(false)
                        switch result.error! {
                        case .clientException:
                            self.view.showError()
                            self.view.navigateToMain()
                        default:
                            self.view.showRetry()
                        }
                    case .inProgress:
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
