import Swift
import RxSwift
import Moya

class ExperienceDataDependencyInjector {
    
    private static let experienceApi = MoyaProvider<ExperienceApi>(plugins:
        AppDataDependencyInjector.moyaPlugins).rx
    private static let realExperienceApiRepository =
        ExperienceApiRepoImplementation(experienceApi, AppDataDependencyInjector.ioScheduler)
    private static let experienceApiRepository =
        ProfileSnifferExperienceApiRepo(realExperienceApiRepository, ProfileDataDependencyInjector.profileRepository)
    
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
           { url in experienceApiRepository.paginateExperiences(url) }),
        RequesterImplementation<ResultCacheImplementation<Experience>>(experienceResultCache,
           { params in experienceApiRepository.personsExperiencesObservable("self") },
           { url in experienceApiRepository.paginateExperiences(url) }),
        RequesterImplementation<ResultCacheImplementation<Experience>>(experienceResultCache,
           { params in experienceApiRepository.personsExperiencesObservable(params!.username!) },
           { url in experienceApiRepository.paginateExperiences(url) }),
        RequesterImplementation<ResultCacheImplementation<Experience>>(
            experienceResultCache,
            { _ in return Observable.empty() },
            { _ in return Observable.empty() })
        )

    static let experienceRepository =
        ExperienceRepoImplementation(apiRepo: experienceApiRepository,
                                     requestersSwitch: requestersSwitch,
                                     ioScheduler: AppDataDependencyInjector.ioScheduler)
}

