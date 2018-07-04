import Swift
import RxSwift

enum Kind {
    case explore
}

protocol ExperienceRepository {
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>>
    func getFirsts(kind: Kind)
    func paginate(kind: Kind)
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>>
    func switchExperienceSaveState(_ experienceId: String)
}

class ExperienceRepoImplementation<R: Requester>: ExperienceRepository
                                                               where R.requesterType == Experience {

    let apiRepo: ExperienceApiRepository!
    let exploreRequester: R!

    init(apiRepo: ExperienceApiRepository, exploreRequester: R) {
        self.apiRepo = apiRepo
        self.exploreRequester = exploreRequester
        self.exploreRequester.getFirstsCallable = { request in
                                                    self.apiRepo.exploreExperiencesObservable() }
        self.exploreRequester.paginateCallable = { url in
                                                    self.apiRepo.paginateExperiences(url)
        }
    }
    
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>> {
        return self.exploreRequester.resultsObservable()
    }
    
    func getFirsts(kind: Kind) {
        self.exploreRequester.actionsObserver.onNext(Request(.getFirsts))
    }
    
    func paginate(kind: Kind) {
        self.exploreRequester.actionsObserver.onNext(Request(.paginate))
    }
    
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return Observable.combineLatest(experiencesObservable(kind: .explore),
                                        experiencesObservable(kind: .explore))
                            { result, result2 in return result }
            .map { result in
                return Result(.success, data:
                    result.data!.filter { experience in return experience.id == experienceId }[0])
        }
    }
    
    func switchExperienceSaveState(_ experienceId: String) {
        _ = (experienceObservable(experienceId)
            .take(1)
            .map { result in
                var modifier = 1
                let isSaved = result.data!.isSaved
                if isSaved { modifier = -1 }
                let updatedExperience = result.data!.builder()
                                            .isSaved(!isSaved)
                                            .savesCount(result.data!.savesCount + modifier)
                                            .build()
                return updatedExperience
            } as Observable<Experience>)
            .subscribe { event in
                switch event {
                case .next(let experience):
                    self.saveExperience(experience.id, save: experience.isSaved)
                    self.exploreRequester.updateObserver.onNext([experience])
                case .error(let error): fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
    
    private func saveExperience(_ experienceId: String, save: Bool) {
        _ = apiRepo.saveExperience(experienceId, save: save)
            .subscribe { event in
                switch event {
                case .next(_): break
                case .error(let error): fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
}
