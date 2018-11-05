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
    let disposeBag = DisposeBag()
    var myProfile: Profile?
    var myExperiences: [Experience]?

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

    func retryClick() {
        getFirstsExperiences()
    }

    private func connectToProfile() {
        self.profileRepo.selfProfile()
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
            .disposed(by: disposeBag)
    }

    private func connectToExperiences() {
        self.experienceRepo.experiencesObservable(kind: .mine)
            .observeOn(self.mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.myExperiences = result.data!
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
        if myProfile != nil && myExperiences != nil {
            if myProfile!.picture == nil || myExperiences!.isEmpty {
                view.showNotEnoughInfoToShare()
            }
            else { view.showShareDialog(self.myProfile!.username) }
        }
    }

    func registerClick() {
        view.navigateToRegister()
    }

    func editProfilePictureClick() {
        view.navigateToPickAndCropImage()
    }

    func imageCropped(_ image: UIImage) {
        profileRepo.uploadProfilePicture(image)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showUploadSuccess()
                    case .error:
                        self.view.showUploadError()
                    case .inProgress:
                        self.view.showUploadInProgress()
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    func bioEdited(_ bio: String) {
        profileRepo.editProfile(bio)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
