import Swift
import RxSwift

class ExploreExperiencesPresenter {
    
    let experienceRepo: ExperienceRepository!
    let authRepo: AuthRepository!
    let mainScheduler: ImmediateSchedulerType!
    
    var view: ExploreExperiencesView!

    init(_ experienceRepository: ExperienceRepository,
         _ authRepository: AuthRepository,
         _ mainScheduler: ImmediateSchedulerType) {
        self.experienceRepo = experienceRepository
        self.authRepo = authRepository
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        getCredentialsAndExperiences()
    }
    
    func retryClick() {
        getCredentialsAndExperiences()
    }
    
    private func getCredentialsAndExperiences() {
        if !self.authRepo.hasPersonCredentials() { getPersonInvitation() }
        else { connectToExperiences() }
    }
    
    private func getPersonInvitation() {
        _ = self.authRepo.getPersonInvitation()
            .observeOn(self.mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showRetry(false)
                        self.view.showLoader(false)
                        self.view.showError(false)
                        self.connectToExperiences()
                    case .error:
                        self.view.showLoader(false)
                        self.view.showError(true)
                        self.view.showRetry(true)
                    case .inProgress:
                        self.view.showRetry(false)
                        self.view.showLoader(true)
                        self.view.showError(false)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
    
    private func connectToExperiences() {
        _ = self.experienceRepo.experiencesObservable()
            .observeOn(self.mainScheduler)
            .debug()
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showRetry(false)
                        self.view.showLoader(false)
                        self.view.showError(false)
                        self.view.show(experiences: result.data!)
                    case .error:
                        self.view.showLoader(false)
                        self.view.showError(true)
                        self.view.showRetry(true)
                    case .inProgress:
                        self.view.showRetry(false)
                        self.view.showError(false)
                        self.view.showLoader(true)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
}

