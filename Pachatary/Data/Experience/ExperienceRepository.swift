import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol ExperienceRepository {
    func experiencesObservable() -> Observable<Result<[Experience]>>
}

class ExperienceRepoImplementation: ExperienceRepository {
    
    let api: Reactive<MoyaProvider<ExperienceApi>>!
    let ioScheduler: ImmediateSchedulerType!
        
    init(_ api: Reactive<MoyaProvider<ExperienceApi>>, _ ioScheduler: ImmediateSchedulerType!) {
        self.api = api
        self.ioScheduler = ioScheduler
    }
    
    func experiencesObservable() -> Observable<Result<[Experience]>> {
        return self.api.request(.searchExperiences)
            .transformNetworkResponse(ExperienceListMapper.self, ioScheduler)
    }
}
