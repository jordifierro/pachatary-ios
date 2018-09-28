import Swift
import Moya

class ExperienceDataDependencyInjector {
    
    private static let experienceApi = MoyaProvider<ExperienceApi>(plugins:
        AppDataDependencyInjector.moyaPlugins).rx
    private static let experienceApiRepository =
        ExperienceApiRepoImplementation(experienceApi, AppDataDependencyInjector.ioScheduler)
    
    private static var experienceResultCache: ResultCacheImplementation<Experience> { get {
        return ResultCacheImplementation<Experience>()
    }}
    private static var experienceRequester:
                            RequesterImplementation<ResultCacheImplementation<Experience>> { get {
        return RequesterImplementation<ResultCacheImplementation<Experience>>(experienceResultCache)
    }}

    static let experienceRepository =
        ExperienceRepoImplementation(apiRepo: experienceApiRepository,
                                     exploreRequester: experienceRequester,
                                     savedRequester: experienceRequester)
}

