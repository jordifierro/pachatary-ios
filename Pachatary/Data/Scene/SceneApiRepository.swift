import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol SceneApiRepository {
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>>
}

class SceneApiRepoImplementation: SceneApiRepository {
    
    let api: Reactive<MoyaProvider<SceneApi>>!
    let ioScheduler: ImmediateSchedulerType!

    init(_ api: Reactive<MoyaProvider<SceneApi>>, _ ioScheduler: ImmediateSchedulerType!) {
        self.api = api
        self.ioScheduler = ioScheduler
    }
    
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        return self.api.request(.experienceScenes(experienceId))
            .transformNetworkListResponse(SceneMapper.self, ioScheduler)
    }
}


