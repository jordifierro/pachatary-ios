import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol ExperienceApiRepository {
    func exploreExperiencesObservable() -> Observable<Result<[Experience]>>
    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>>
}

class ExperienceApiRepoImplementation: ExperienceApiRepository {
    
    let api: Reactive<MoyaProvider<ExperienceApi>>!
    let ioScheduler: ImmediateSchedulerType!

    init(_ api: Reactive<MoyaProvider<ExperienceApi>>, _ ioScheduler: ImmediateSchedulerType!) {
        self.api = api
        self.ioScheduler = ioScheduler
    }
    
    func exploreExperiencesObservable() -> Observable<Result<[Experience]>> {
        return self.api.request(.searchExperiences)
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }
    
    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>> {
        return self.api.request(.paginate(url))
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }
}
