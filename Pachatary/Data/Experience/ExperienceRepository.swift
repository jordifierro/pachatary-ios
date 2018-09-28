import Swift
import RxSwift

enum Kind {
    case explore
    case saved
}

protocol ExperienceRepository {
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>>
    func getFirsts(kind: Kind, params: Request.Params?)
    func paginate(kind: Kind)
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>>
    func saveExperience(_ experienceId: String, save: Bool)
}

class ExperienceRepoImplementation<R: Requester>: ExperienceRepository
                                                               where R.requesterType == Experience {

    let apiRepo: ExperienceApiRepository!
    let exploreRequester: R!
    let savedRequester: R!

    init(apiRepo: ExperienceApiRepository, exploreRequester: R, savedRequester: R) {
        self.apiRepo = apiRepo
        self.exploreRequester = exploreRequester
        self.savedRequester = savedRequester
        
        self.exploreRequester.getFirstsCallable =
            { params in
                self.apiRepo.exploreExperiencesObservable(
                    params!.word, params!.latitude, params!.longitude) }
        self.exploreRequester.paginateCallable = { url in
                                                    self.apiRepo.paginateExperiences(url) }
        self.savedRequester.getFirstsCallable =
            { params in self.apiRepo.savedExperiencesObservable() }
        self.savedRequester.paginateCallable = { url in self.apiRepo.paginateExperiences(url)
        }
    }
    
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>> {
        switch kind {
        case .explore:
            return self.exploreRequester.resultsObservable()
        case .saved:
            return self.savedRequester.resultsObservable()
                .map({ (result) -> Result<[Experience]> in
                    result.builder()
                        .data(result.data!.filter({ (experience) -> Bool in experience.isSaved }))
                        .build()
                })
        }
    }
    
    func getFirsts(kind: Kind, params: Request.Params? = nil) {
        switch kind {
        case .explore:
            self.exploreRequester.actionsObserver.onNext(Request(.getFirsts, params))
        case .saved:
            self.savedRequester.actionsObserver.onNext(Request(.getFirsts))
        }
    }
    
    func paginate(kind: Kind) {
        switch kind {
        case .explore:
            self.exploreRequester.actionsObserver.onNext(Request(.paginate))
        case .saved:
            self.savedRequester.actionsObserver.onNext(Request(.paginate))
        }
    }
    
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return Observable.combineLatest(experiencesObservable(kind: .explore),
                                        experiencesObservable(kind: .saved))
                            { result, result2 in return result }
            .map { result in
                return Result(.success, data:
                    result.data!.filter { experience in return experience.id == experienceId }[0])
        }
    }
    
    func saveExperience(_ experienceId: String, save: Bool) {
        saveExperienceOnApiRepo(experienceId, save: save)
        updateCache(experienceId, save: save)
    }
    
    private func saveExperienceOnApiRepo(_ experienceId: String, save: Bool) {
        _ = apiRepo.saveExperience(experienceId, save: save)
            .subscribe { event in
                switch event {
                case .next(_): break
                case .error(let error): fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
    
    private func updateCache(_ experienceId: String, save: Bool) {
        _ = (experienceObservable(experienceId)
            .take(1)
            .map { result in
                var modifier = 1
                if !save { modifier = -1 }
                let updatedExperience = result.data!.builder()
                    .isSaved(save)
                    .savesCount(result.data!.savesCount + modifier)
                    .build()
                return updatedExperience
            } as Observable<Experience>)
            .subscribe { event in
                switch event {
                case .next(let experience):
                    self.exploreRequester.updateObserver.onNext([experience])
                    self.savedRequester.addOrUpdateObserver.onNext([experience])
                case .error(let error): fatalError(error.localizedDescription)
                case .completed: break
            }
        }
    }
}
