import Swift
import RxSwift

class ExperienceScenesPresenter {
    
    let sceneRepo: SceneRepository!
    let experienceRepo: ExperienceRepository!
    let mainScheduler: ImmediateSchedulerType!
    unowned let view: ExperienceScenesView
    let experienceId: String!
    var selectedSceneId: String? = nil
    var disposeBag: DisposeBag? = DisposeBag()

    init(_ sceneRepo: SceneRepository, _ experienceRepo: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType, _ view: ExperienceScenesView,
         _ experienceId: String) {
        self.sceneRepo = sceneRepo
        self.experienceRepo = experienceRepo
        self.mainScheduler = mainScheduler
        self.view = view
        self.experienceId = experienceId
    }
    
    func create() {
        getExperienceAndScenes()
    }

    func retry() {
        getExperienceAndScenes()
    }

    func resume() {
        if (selectedSceneId != nil) {
            view.scrollToScene(selectedSceneId!)
            selectedSceneId = nil
        }
    }

    func destroy() {
        self.disposeBag = nil
    }
    
    func onGoToMapClick() {
        view.navigateToMap(nil)
    }

    func onLocateSceneClick(_ sceneId: String) {
        view.navigateToMap(sceneId)
    }
    
    func saveExperience(save: Bool) {
        if save { experienceRepo.saveExperience(self.experienceId, save: save) }
        else { view.showUnsaveConfirmationDialog() }
    }

    func onUnsaveDialogOk() {
        experienceRepo.saveExperience(self.experienceId, save: false)
    }

    func onUnsaveDialogCancel() {}

    func shareClick() {
        experienceRepo.shareUrl(experienceId)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showShareDialog(result.data!)
                    case .error: break
                    case .inProgress: break
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
            .disposed(by: disposeBag!)
    }

    func profileClick(_ username: String) {
        view.navigateToProfile(username)
    }

    private func getExperienceAndScenes() {
        connectToExperience()
        connectToScenes()
    }

    private func connectToExperience() {
        experienceRepo.experienceObservable(experienceId)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showExperience(result.data!)
                        self.view.showExperienceLoading(false)
                    case .error:
                        self.view.showExperienceLoading(false)
                        self.view.showRetry()
                    case .inProgress:
                        self.view.showExperienceLoading(true)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
            .disposed(by: disposeBag!)
    }

    private func connectToScenes() {
        sceneRepo.scenesObservable(experienceId: experienceId)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showScenes(result.data!)
                        self.view.showSceneLoading(false)
                    case .error:
                        self.view.showSceneLoading(false)
                        self.view.showRetry()
                    case .inProgress:
                        self.view.showSceneLoading(true)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
            .disposed(by: disposeBag!)
    }
}
