import Swift
import RxSwift

class AskLoginEmailPresenter {
    
    var authRepository: AuthRepository!
    var mainScheduler: ImmediateSchedulerType!
    var view: AskLoginEmailView!
    
    init(_ authRepository: AuthRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
    }
    
    func onAskClick(_ email: String) {
        _ = authRepository.askLoginEmail(email)
            .observeOn(mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.finishApp()
                    case .error:
                        self.view.enableButton()
                    case .inProgress:
                        self.view.disableButton()
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
}
