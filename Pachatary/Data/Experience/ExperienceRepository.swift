import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol ExperienceRepository {
    func experiencesObservable() -> Observable<[Experience]>
}

class ExperienceRepoImplementation: ExperienceRepository {
    
    let api: Reactive<MoyaProvider<ExperienceApi>>!
        
    init(_ api: Reactive<MoyaProvider<ExperienceApi>>) {
        self.api = api
    }
    
    func experiencesObservable() -> Observable<[Experience]> {
        return self.api.request(.searchExperiences)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .mapObject(ExperienceListMapper.self)
            .map { mapper in return mapper.toDomain() }
            .asObservable()
    }
}
