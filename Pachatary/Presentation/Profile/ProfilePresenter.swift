import Swift
import RxSwift

class ProfilePresenter {
    
    let experienceRepo: ExperienceRepository
    let profileRepo: ProfileRepository
    let mainScheduler: ImmediateSchedulerType
    
    unowned let view: ProfileView
    let username: String
    
    var experiencesDisposable: Disposable? = nil
    var profileDisposable: Disposable? = nil
    
    init(_ experienceRepository: ExperienceRepository,
         _ profileRepository: ProfileRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: ProfileView,
         _ username: String) {
        self.experienceRepo = experienceRepository
        self.profileRepo = profileRepository
        self.mainScheduler = mainScheduler
        self.view = view
        self.username = username
    }
    
    func create() {
        connectToExperiences()
        getFirstsExperiences()
        connectToProfile()
    }
    
    func destroy() {
        self.experiencesDisposable?.dispose()
        self.profileDisposable?.dispose()
    }
    
    func retryClick() {
        getFirstsExperiences()
    }
    
    private func connectToProfile() {
        profileDisposable = self.profileRepo.profile(username)
            .observeOn(self.mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showLoadingProfile(false)
                        self.view.showProfile(result.data!)
                    case .error:
                        self.view.showLoadingProfile(false)
                        self.view.showRetry()
                    case .inProgress:
                        self.view.showLoadingProfile(true)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
    
    private func connectToExperiences() {
        experiencesDisposable = self.experienceRepo.experiencesObservable(kind: .persons)
            .observeOn(self.mainScheduler)
            .filter({ [unowned self] result in
                        result.params == Request.Params(username: self.username) })
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showLoadingExperiences(false)
                        self.view.showExperiences(result.data!)
                    case .error:
                        self.view.showLoadingExperiences(false)
                        self.view.showRetry()
                    case .inProgress:
                        self.view.showExperiences(result.data!)
                        self.view.showLoadingExperiences(true)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
        }
    }
    
    private func getFirstsExperiences() {
        self.experienceRepo.getFirsts(kind: .persons, params: Request.Params(username: self.username))
    }
    
    func lastItemShown() {
        self.experienceRepo.paginate(kind: .persons)
    }
    
    func experienceClick(_ experienceId: String) {
        view.navigateToExperienceScenes(experienceId)
    }
    
    func refresh() {
        getFirstsExperiences()
    }
}
