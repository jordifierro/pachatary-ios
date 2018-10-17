import Swift
import RxSwift

protocol ExperienceRepository {
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>>
    func getFirsts(kind: Kind, params: Request.Params?)
    func paginate(kind: Kind)
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>>
    func saveExperience(_ experienceId: String, save: Bool)
    func translateShareId(_ shareId: String) -> Observable<Result<String>>
    func shareUrl(_ experienceId: String) -> Observable<Result<String>>
}

class ExperienceRepoImplementation: ExperienceRepository {

    let apiRepo: ExperienceApiRepository!
    let requestersSwitch: ExperienceRequestersSwitch!

    init(apiRepo: ExperienceApiRepository, requestersSwitch: ExperienceRequestersSwitch) {
        self.apiRepo = apiRepo
        self.requestersSwitch = requestersSwitch
    }
    
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>> {
        switch kind {
        case .saved:
            return self.requestersSwitch.experiencesObservable(.saved)
                .map({ (result) -> Result<[Experience]> in
                    result.builder()
                        .data(result.data!.filter({ (experience) -> Bool in experience.isSaved }))
                        .build()
                })
        default:
            return self.requestersSwitch.experiencesObservable(kind)
        }
    }
    
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return self.requestersSwitch.experienceObservable(experienceId)
            .flatMap { (result: Result<Experience>) -> Observable<Result<Experience>> in
                if result.error == DataError.notCached {
                    return self.apiRepo.experienceObservable(experienceId)
                        .do(onNext: { result in
                            if result.status == .success {
                                self.requestersSwitch.modifyResult(
                                    .other, .addOrUpdate, list: [result.data!], result: nil)
                            }
                        })
                }
                else { return Observable.just(result) }
        }
    }
    
    func getFirsts(kind: Kind, params: Request.Params? = nil) {
        self.requestersSwitch.executeAction(kind, Request(.getFirsts, params))
    }
    
    func paginate(kind: Kind) {
        self.requestersSwitch.executeAction(kind, Request(.paginate))
    }

    func saveExperience(_ experienceId: String, save: Bool) {
        saveExperienceOnApiRepo(experienceId, save: save)
        updateCache(experienceId, save: save)
    }

    func shareUrl(_ experienceId: String) -> Observable<Result<String>> {
        return apiRepo.shareUrl(experienceId)
    }

    func translateShareId(_ shareId: String) -> Observable<Result<String>> {
        return apiRepo.translateShareId(shareId)
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
                    self.requestersSwitch.modifyResult(.explore, .update,
                                                       list: [experience], result: nil)
                    self.requestersSwitch.modifyResult(.persons, .update,
                                                       list: [experience], result: nil)
                    self.requestersSwitch.modifyResult(.other, .update,
                                                       list: [experience], result: nil)
                    self.requestersSwitch.modifyResult(.saved, .addOrUpdate,
                                                       list: [experience], result: nil)
                case .error(let error): fatalError(error.localizedDescription)
                case .completed: break
            }
        }
    }
}
