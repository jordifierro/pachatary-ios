import Swift
import RxSwift

enum Kind {
    case explore
}

protocol ExperienceRepository {
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>>
    func getFirsts(kind: Kind)
    func paginate(kind: Kind)
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
}


