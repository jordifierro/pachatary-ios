import Swift
import RxSwift

class LoginPresenter {
    
    var authRepository: AuthRepository!
    var mainScheduler: ImmediateSchedulerType!
    var view: LoginView!
    var token: String!
    
    init(_ authRepository: AuthRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        _ = authRepository.login(token)
            .observeOn(mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.navigateToMain()
                    case .error: break
                    case .inProgress: break
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
        }
    }
}


