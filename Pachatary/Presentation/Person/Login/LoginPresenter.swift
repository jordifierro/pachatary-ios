import Swift
import RxSwift

class LoginPresenter {
    
    var authRepository: AuthRepository!
    var mainScheduler: ImmediateSchedulerType!
    var view: LoginView!
    var token: String!
    let disposeBag = DisposeBag()
    
    init(_ authRepository: AuthRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
    }

    func create() {
        login()
    }

    func retry() {
        login()
    }

    private func login() {
        authRepository.login(token)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.navigateToMain()
                    case .error:
                        self.view.showLoader(false)
                        switch result.error! {
                        case .clientException:
                            self.view.showError()
                            self.view.navigateToAskLoginEmail()
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
