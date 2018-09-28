import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol ExperienceApiRepository {
    func exploreExperiencesObservable(_ text: String?, _ latitude: Double?, _ longitude: Double?)
                                                                -> Observable<Result<[Experience]>>
    func savedExperiencesObservable() -> Observable<Result<[Experience]>>
    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>>
    func saveExperience(_ experienceId: String, save: Bool) -> Observable<Result<Bool>>
}

class ExperienceApiRepoImplementation: ExperienceApiRepository {
    
    let api: Reactive<MoyaProvider<ExperienceApi>>!
    let ioScheduler: ImmediateSchedulerType!

    init(_ api: Reactive<MoyaProvider<ExperienceApi>>, _ ioScheduler: ImmediateSchedulerType!) {
        self.api = api
        self.ioScheduler = ioScheduler
    }
    
    func exploreExperiencesObservable(_ text: String?, _ latitude: Double?,
                                      _ longitude: Double?) -> Observable<Result<[Experience]>> {
        return self.api.request(.search(text ?? "", latitude, longitude))
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }
    
    func savedExperiencesObservable() -> Observable<Result<[Experience]>> {
        return self.api.request(.saved)
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }

    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>> {
        return self.api.request(.paginate(url))
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }
    
    func saveExperience(_ experienceId: String, save: Bool) -> Observable<Result<Bool>> {
        return self.api.request(.save(experienceId, save))
            .transformNetworkVoidResponse(ioScheduler)
    }
}
