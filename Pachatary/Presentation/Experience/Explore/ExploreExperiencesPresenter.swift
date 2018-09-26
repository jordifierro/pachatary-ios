import Swift
import RxSwift

class ExploreExperiencesPresenter {
    
    let experienceRepo: ExperienceRepository
    let mainScheduler: ImmediateSchedulerType
    
    var view: ExploreExperiencesView!
    
    var text: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil

    init(_ experienceRepository: ExperienceRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.experienceRepo = experienceRepository
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        connectToExperiences()
        if view.hasLocationPermission() { view.askLastKnownLocation() }
        else { view.askLocationPermission() }
    }
    
    func onPermissionAccepted() {
        view.askLastKnownLocation()
    }
    
    func onPermissionDenied() {
        getFirstsExperiences()
    }
    
    func onLastLocationFound(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        getFirstsExperiences()
    }
    
    func onLastLocationNotFound() {
        getFirstsExperiences()
    }
    
    func retryClick() {
        getFirstsExperiences()
    }

    private func connectToExperiences() {
        _ = self.experienceRepo.experiencesObservable(kind: .explore)
            .observeOn(self.mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showRetry(false)
                        self.view.showLoader(false)
                        self.view.showError(false)
                        self.view.showPaginationLoader(false)
                        self.view.show(experiences: result.data!)
                    case .error:
                        self.view.showLoader(false)
                        self.view.showError(true)
                        self.view.showRetry(true)
                        self.view.showPaginationLoader(false)
                    case .inProgress:
                        self.view.showRetry(false)
                        self.view.showError(false)
                        switch result.action! {
                        case .getFirsts:
                            self.view.showLoader(true)
                            self.view.showPaginationLoader(false)
                        case .paginate:
                            self.view.showLoader(false)
                            self.view.showPaginationLoader(true)
                        case .none: break
                        case .refresh: break
                        }
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
    
    private func getFirstsExperiences() {
        self.experienceRepo.getFirsts(kind: .explore,
            params: Request.Params(self.text, self.latitude, self.longitude))
    }
    
    func lastItemShown() {
        self.experienceRepo.paginate(kind: .explore)
    }
    
    func experienceClick(_ experienceId: String) {
        view.navigateToExperienceScenes(experienceId)
    }
    
    func searchClick(_ text: String) {
        self.text = text
        getFirstsExperiences()
    }
}

