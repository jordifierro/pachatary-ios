import Swift
import RxSwift

class SavedExperiencesPresenter {
    
    let experienceRepo: ExperienceRepository
    let mainScheduler: ImmediateSchedulerType
    
    unowned let view: SavedExperiencesView
    
    var disposable: Disposable? = nil
    
    var text: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    init(_ experienceRepository: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: SavedExperiencesView) {
        self.experienceRepo = experienceRepository
        self.mainScheduler = mainScheduler
        self.view = view
    }
    
    func create() {
        connectToExperiences()
        getFirstsExperiences()
    }
    
    func destroy() {
        self.disposable?.dispose()
    }
    
    func retryClick() {
        getFirstsExperiences()
    }
    
    private func connectToExperiences() {
        disposable = self.experienceRepo.experiencesObservable(kind: .saved)
            .observeOn(self.mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showLoader(false)
                        self.view.show(experiences: result.data!)
                    case .error:
                        self.view.showLoader(false)
                        self.view.showRetry()
                    case .inProgress:
                        self.view.show(experiences: result.data!)
                        self.view.showLoader(true)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
        }
    }
    
    private func getFirstsExperiences() {
        self.experienceRepo.getFirsts(kind: .saved, params: nil)
    }
    
    func lastItemShown() {
        self.experienceRepo.paginate(kind: .saved)
    }
    
    func experienceClick(_ experienceId: String) {
        view.navigateToExperienceScenes(experienceId)
    }
    
    func refresh() {
        getFirstsExperiences()
    }
}


