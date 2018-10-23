import Swift
import RxSwift

class AskLoginEmailPresenter {
    
    var authRepository: AuthRepository!
    var mainScheduler: ImmediateSchedulerType!
    var view: AskLoginEmailView!
    var disposeBag: DisposeBag? = DisposeBag()
    
    init(_ authRepository: AuthRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
    }

    deinit {
        disposeBag = nil
    }
    
    func onAskClick(_ email: String) {
        if email.count == 0 { view.showEmptyEmailError() }
        else {
            authRepository.askLoginEmail(email)
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
                            self.view.showError()
                        case .inProgress:
                            self.view.disableButton()
                            self.view.showLoader(true)
                        }
                    case .error(let error):
                        fatalError(error.localizedDescription)
                    case .completed: break
                    }
                }
                .disposed(by: disposeBag!)
        }
    }
}
