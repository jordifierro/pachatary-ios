import Swift
import RxSwift

class MyExperiencesPresenter {

    let experienceRepo: ExperienceRepository
    let profileRepo: ProfileRepository
    let authRepository: AuthRepository
    let mainScheduler: ImmediateSchedulerType

    unowned let view: MyExperiencesView

    var experiencesDisposable: Disposable? = nil
    var profileDisposable: Disposable? = nil
    var myProfile: Profile?

    init(_ experienceRepository: ExperienceRepository,
         _ profileRepository: ProfileRepository,
         _ authRepository: AuthRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: MyExperiencesView) {
        self.experienceRepo = experienceRepository
        self.profileRepo = profileRepository
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
        self.view = view
    }


    func create() {
        if authRepository.isRegisterCompleted() {
            view.showProfileAndExperiencesView()
            connectToExperiences()
            getFirstsExperiences()
            connectToProfile()
        }
        else {
            view.showRegisterView()
        }
    }

    func destroy() {
        self.experiencesDisposable?.dispose()
        self.profileDisposable?.dispose()
    }

    func retryClick() {
        getFirstsExperiences()
    }

    private func connectToProfile() {
        profileDisposable = self.profileRepo.selfProfile()
            .observeOn(self.mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.myProfile = result.data!
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
        experiencesDisposable = self.experienceRepo.experiencesObservable(kind: .mine)
            .observeOn(self.mainScheduler)
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
        self.experienceRepo.getFirsts(kind: .mine, params: nil)
    }

    func lastItemShown() {
        self.experienceRepo.paginate(kind: .mine)
    }

    func experienceClick(_ experienceId: String) {
        view.navigateToExperienceScenes(experienceId)
    }

    func refresh() {
        getFirstsExperiences()
    }

    func shareClick() {
        if self.myProfile != nil {
            view.showShareDialog(self.myProfile!.username)
        }
    }

    func registerClick() {
        view.navigateToRegister()
    }
}
