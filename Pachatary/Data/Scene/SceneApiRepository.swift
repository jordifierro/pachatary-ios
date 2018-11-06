import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol SceneApiRepository {
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>>
    func createScene(_ experienceId: String, _ title: String, _ description: String,
                     _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>>
    func uploadPicture(_ sceneId: String, _ image: UIImage) -> Observable<Result<Scene>>
    func editScene(_ sceneId: String, _ title: String, _ description: String,
                   _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>>
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

    func createScene(_ experienceId: String, _ title: String, _ description: String,
                     _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>> {
        return self.api.request(.create(experienceId: experienceId,
                                        title: title, description: description,
                                        latitude: latitude, longitude: longitude))
            .transformNetworkResponse(SingleResultMapper<SceneMapper>.self, ioScheduler)
    }

    func uploadPicture(_ sceneId: String, _ image: UIImage) -> Observable<Result<Scene>> {
        return self.api.request(.uploadPicture(sceneId: sceneId, picture: image))
            .transformNetworkResponse(SingleResultMapper<SceneMapper>.self, ioScheduler)
    }

    func editScene(_ sceneId: String, _ title: String, _ description: String,
                   _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>> {
        return self.api.request(.edit(sceneId: sceneId,
                                      title: title, description: description,
                                      latitude: latitude, longitude: longitude))
            .transformNetworkResponse(SingleResultMapper<SceneMapper>.self, ioScheduler)
    }
}
