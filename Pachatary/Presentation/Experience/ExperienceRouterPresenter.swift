import Swift
import RxSwift

class ExperienceRouterPresenter {

    let authRepo: AuthRepository
    let experienceRepo: ExperienceRepository
    let mainScheduler: ImmediateSchedulerType
    unowned let view: ExperienceRouterView
    let experienceShareId: String
    var authDisposable: Disposable?
    var experienceDisposable: Disposable?

    init(_ authRepo: AuthRepository, _ experienceRepo: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: ExperienceRouterView, _ experienceShareId: String) {
        self.authRepo = authRepo
        self.experienceRepo = experienceRepo
        self.mainScheduler = mainScheduler
        self.view = view
        self.experienceShareId = experienceShareId
    }

    func create() {
        getPersonCredentialsTranslateShareIdAndNavigateToExperience()
    }

    func retry() {
        getPersonCredentialsTranslateShareIdAndNavigateToExperience()
    }

    func destroy() {
        self.authDisposable?.dispose()
        self.experienceDisposable?.dispose()
    }

    private func getPersonCredentialsTranslateShareIdAndNavigateToExperience() {
        if authRepo.hasPersonCredentials() { translateShareIdAndNavigateToExperience() }
        else {
            authDisposable = authRepo.getPersonInvitation()
                .subscribeOn(mainScheduler)
                .subscribe { [unowned self] event in
                    switch event {
                    case .next(let result):
                        switch result.status {
                        case .success:
                            self.translateShareIdAndNavigateToExperience()
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
        }
    }

    private func translateShareIdAndNavigateToExperience() {
        experienceDisposable = experienceRepo.translateShareId(self.experienceShareId)
            .subscribeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.navigateToExperience(result.data!)
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
    }
}
