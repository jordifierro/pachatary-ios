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

    private static let requestersSwitch = ExperienceRequestersSwitchImplementation(
        RequesterImplementation<ResultCacheImplementation<Experience>>(experienceResultCache,
           { params in
                experienceApiRepository.exploreExperiencesObservable(
                    params!.word, params!.latitude, params!.longitude) },
           { url in experienceApiRepository.paginateExperiences(url) }),
        RequesterImplementation<ResultCacheImplementation<Experience>>(experienceResultCache,
           { params in experienceApiRepository.savedExperiencesObservable() },
           { url in experienceApiRepository.paginateExperiences(url) }))

    static let experienceRepository =
        ExperienceRepoImplementation(apiRepo: experienceApiRepository,
                                     requestersSwitch: requestersSwitch)
}

