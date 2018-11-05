import Swift
import RxSwift

class ProfileRouterPresenter {

    let authRepo: AuthRepository
    let mainScheduler: ImmediateSchedulerType
    unowned let view: ProfileRouterView
    let username: String
    let disposeBag = DisposeBag()

    init(_ authRepo: AuthRepository, _ mainScheduler: ImmediateSchedulerType,
         _ view: ProfileRouterView, _ username: String) {
        self.authRepo = authRepo
        self.mainScheduler = mainScheduler
        self.view = view
        self.username = username
    }

    func create() {
        getPersonCredentialsAndNavigateToProfile()
    }

    func retry() {
        getPersonCredentialsAndNavigateToProfile()
    }

    private func getPersonCredentialsAndNavigateToProfile() {
        if authRepo.hasPersonCredentials() { view.navigateToProfile(username) }
        else {
            authRepo.getPersonInvitation()
                .subscribeOn(mainScheduler)
                .subscribe { [unowned self] event in
                    switch event {
                    case .next(let result):
                        switch result.status {
                        case .success:
                            self.view.navigateToProfile(self.username)
                        case .error:
                            self.view.showLoading(false)
                            self.view.showRetry()
                        case .inProgress:
                            self.view.showLoading(true)
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
