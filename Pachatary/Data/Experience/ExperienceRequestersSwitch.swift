import Swift
import RxSwift

enum Kind {
    case explore
    case saved
    case mine
    case persons
    case other
}

enum Modification {
    case addOrUpdate
    case update
}

protocol ExperienceRequestersSwitch {
    func executeAction(_ kind: Kind, _ request: Request)
    func modifyResult(_ kind: Kind, _ modification: Modification,
                      list: [Experience]?, result: Result<[Experience]>?)
    func remove(_ kind: Kind, _ allItemsThat: @escaping (Experience) -> Bool)
    func experiencesObservable(_ kind: Kind) -> Observable<Result<[Experience]>>
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>>
}

class ExperienceRequestersSwitchImplementation<R: Requester>: ExperienceRequestersSwitch
where R.requesterType == Experience {

    let exploreRequester: R!
    let savedRequester: R!
    let mineRequester: R!
    let personsRequester: R!
    let otherRequester: R!

    init(_ exploreRequester: R, _ savedRequester: R, _ mineRequester: R,
         _ personsRequester: R, _ otherRequester: R) {
        self.exploreRequester = exploreRequester
        self.savedRequester = savedRequester
        self.mineRequester = mineRequester
        self.personsRequester = personsRequester
        self.otherRequester = otherRequester
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

    func remove(_ kind: Kind, _ allItemsThat: @escaping (Experience) -> Bool) {
        requester(kind).remove(allItemsThat)
    }

    func experiencesObservable(_ kind: Kind) -> Observable<Result<[Experience]>> {
        return requester(kind).resultsObservable()
    }

    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return Observable.combineLatest(experiencesObservable(.explore),
                                        experiencesObservable(.saved),
                                        experiencesObservable(.mine),
                                        experiencesObservable(.persons),
                                        experiencesObservable(.other))
            { result1, result2, result3, result4, result5 in
                var experiences = [Experience]()
                if result1.data != nil { experiences += result1.data! }
                if result2.data != nil { experiences += result2.data! }
                if result3.data != nil { experiences += result3.data! }
                if result4.data != nil { experiences += result4.data! }
                if result5.data != nil { experiences += result5.data! }
                return experiences
            }
            .map { (experiences: [Experience]) -> Experience? in
                let filteredExperiences =
                    experiences.filter { experience in return experience.id == experienceId }
                if filteredExperiences.isEmpty { return nil }
                else { return filteredExperiences.first }
            }
            .map { experience in
                if experience == nil { return Result(.error, error: DataError.notCached) }
                else { return Result(.success, data: experience) }
            }
    }

    private func requester(_ kind: Kind) -> R {
        switch kind {
        case .explore:
            return self.exploreRequester
        case .saved:
            return self.savedRequester
        case .mine:
            return self.mineRequester
        case .persons:
            return self.personsRequester
        case .other:
            return self.otherRequester
        }
    }
}
