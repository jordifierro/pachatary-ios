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
        if self.authRepo.hasPersonCredentials() { connectToExperiences() }
        else { getPersonInvitation() }
    }
    
    private func connectToExperiences() {
        _ = self.experienceRepo.experiencesObservable()
            .observeOn(self.mainScheduler)
            .subscribe(onNext: { experiences in self.view.show(experiences: experiences) })
    }
    
    private func getPersonInvitation() {
        _ = self.authRepo.getPersonInvitation()
            .observeOn(self.mainScheduler)
            .subscribe { self.connectToExperiences() }
    }
}

