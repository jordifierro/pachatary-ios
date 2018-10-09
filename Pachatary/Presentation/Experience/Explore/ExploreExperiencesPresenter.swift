import Swift
import RxSwift

class ExploreExperiencesPresenter {
    
    let experienceRepo: ExperienceRepository
    let mainScheduler: ImmediateSchedulerType
    
    unowned let view: ExploreExperiencesView

    var disposable: Disposable? = nil
    
    var text: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil

    init(_ experienceRepository: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: ExploreExperiencesView) {
        self.experienceRepo = experienceRepository
        self.mainScheduler = mainScheduler
        self.view = view
    }

    func create() {
        connectToExperiences()
        if view.hasLocationPermission() { view.askLastKnownLocation() }
        else { view.askLocationPermission() }
    }
    
    func destroy() {
        self.disposable?.dispose()
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
        disposable = self.experienceRepo.experiencesObservable(kind: .explore)
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
    
    func refresh() {
        getFirstsExperiences()
    }

    func profileClick(_ username: String) {
        self.view.navigateToProfile(username)
    }

    func onSelectLocationClick() {
        view.navigateToSelectLocation(latitude, longitude)
    }
}
