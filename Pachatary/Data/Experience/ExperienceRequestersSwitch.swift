import Swift
import RxSwift

enum Kind {
    case explore
    case saved
}

enum Modification {
    case addOrUpdate
    case update
}

protocol ExperienceRequestersSwitch {
    func executeAction(_ kind: Kind, _ request: Request)
    func modifyResult(_ kind: Kind, _ modification: Modification,
                      list: [Experience]?, result: Result<[Experience]>?)
    func experiencesObservable(_ kind: Kind) -> Observable<Result<[Experience]>>
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>>
}

class ExperienceRequestersSwitchImplementation<R: Requester>: ExperienceRequestersSwitch
                                                               where R.requesterType == Experience {

    let exploreRequester: R!
    let savedRequester: R!

    init(_ exploreRequester: R, _ savedRequester: R) {
        self.exploreRequester = exploreRequester
        self.savedRequester = savedRequester
    }

    func executeAction(_ kind: Kind, _ request: Request) {
        requester(kind).request(request)
    }

    func modifyResult(_ kind: Kind, _ modification: Modification,
                      list: [Experience]? = nil, result: Result<[Experience]>? = nil) {
        switch modification {
        case .update:
            requester(kind).update(list!)
        case .addOrUpdate:
            requester(kind).addOrUpdate(list!)
        }
    }

    func experiencesObservable(_ kind: Kind) -> Observable<Result<[Experience]>> {
        return requester(kind).resultsObservable()
    }

    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return Observable.combineLatest(experiencesObservable(.explore),
                                        experiencesObservable(.saved))
        { result, result2 in return result }
            .map { result in
                return Result(.success, data:
                    result.data!.filter { experience in return experience.id == experienceId }[0])
        }
    }

    private func requester(_ kind: Kind) -> R {
        switch kind {
        case .explore:
            return self.exploreRequester
        case .saved:
            return self.savedRequester
        }
    }
}
