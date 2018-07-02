import Swift
import Moya

class SceneDataDependencyInjector {
    
    private static let sceneApi =
        MoyaProvider<SceneApi>(plugins: AppDataDependencyInjector.moyaPlugins).rx
    private static let sceneApiRepository =
        SceneApiRepoImplementation(sceneApi, AppDataDependencyInjector.ioScheduler)
    
    private static var sceneResultCache: ResultCacheImplementation<Scene> { get {
        return ResultCacheImplementation<Scene>()
        }}

    static let sceneRepository = SceneRepoImplementation(
        apiRepo: sceneApiRepository, generateNewCache: { return sceneResultCache })
}
