import Swift
import RxSwift
import Moya

class ExperienceDependencyInjector {
    
#if DEBUG
    static let debug: Bool = true
#else
    static let debug: Bool = false
#endif
    
    private static let apiKeysPath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
    private static let apiKeysDict = NSDictionary(contentsOfFile: apiKeysPath!)

    static var apiUrl: String { get {
            if debug { return apiKeysDict!["devApiUrl"] as! String }
            else { return apiKeysDict!["apiUrl"] as! String }
        }}
    private static var clientSecretKey: String { get {
            if debug { return apiKeysDict!["devClientSecretKey"] as! String }
            else { return apiKeysDict!["clientSecretKey"] as! String }
        }}
    private static let ioScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    private static let authStorageRepository = AuthStorageRepoImplementation()
    private static let authHeaderPlugin = AuthHeaderPlugin(authStorageRepository)
    private static let clientVersionPlugin = ClientVersionPlugin()
    private static let moyaPlugins = [authHeaderPlugin, clientVersionPlugin] as [PluginType]
    private static let authApi = MoyaProvider<AuthApi>(plugins: moyaPlugins).rx
    private static let authApiRepository =
        AuthApiRepoImplementation(authApi, clientSecretKey, ioScheduler)
    private static let authRepository =
        AuthRepoImplementation(authStorageRepository, authApiRepository)

    private static let mainScheduler: ImmediateSchedulerType! = MainScheduler.instance
    private static let experienceApi = MoyaProvider<ExperienceApi>(plugins: moyaPlugins).rx
    private static let experienceRepository = ExperienceRepoImplementation(experienceApi)
    static var exploreExperiencePresenter: ExploreExperiencesPresenter { get {
        return ExploreExperiencesPresenter(experienceRepository, authRepository, mainScheduler) }
    }
}

