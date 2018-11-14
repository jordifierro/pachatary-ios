import Swift
import RxSwift

class ProfilePresenter {
    
    let experienceRepo: ExperienceRepository
    let profileRepo: ProfileRepository
    let authRepo: AuthRepository
    let mainScheduler: ImmediateSchedulerType
    
    unowned let view: ProfileView
    let username: String

    let disposeBag = DisposeBag()

    init(_ experienceRepository: ExperienceRepository,
         _ profileRepository: ProfileRepository,
         _ authRepository: AuthRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: ProfileView,
         _ username: String) {
        self.experienceRepo = experienceRepository
        self.profileRepo = profileRepository
        self.authRepo = authRepository
        self.mainScheduler = mainScheduler
        self.view = view
        self.username = username
    }
    
    func create() {
        connectToExperiences()
        getFirstsExperiences()
        connectToProfile()
    }
    
    func retryClick() {
        getFirstsExperiences()
    }
    
    private func connectToProfile() {
        self.profileRepo.profile(username)
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
            .disposed(by: disposeBag)
    }
    
    private func connectToExperiences() {
        self.experienceRepo.experiencesObservable(kind: .persons)
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
            .disposed(by: disposeBag)
    }
    
    private func getFirstsExperiences() {
        self.experienceRepo.getFirsts(kind: .persons,
                                      params: Request.Params(username: self.username))
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

    func shareClick() {
        view.showShareDialog(username)
    }

    func blockClick() {
        view.showBlockExplanationDialog()
    }

    func blockConfirmed() {
        authRepo.blockPerson(username)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success: self.view.showBlockSuccess()
                    case .error: self.view.showBlockError()
                    case .inProgress: break
                    }
                case .error(let error): fatalError(error.localizedDescription)
                case .completed: break
                }
            }
            .disposed(by: disposeBag)
    }
}
