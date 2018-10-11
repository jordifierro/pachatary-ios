import Swift
import Moya

class ProfileDataDependencyInjector {

    private static let profileApi = MoyaProvider<ProfileApi>(plugins:
        AppDataDependencyInjector.moyaPlugins).rx
    private static let profileApiRepository =
        ProfileApiRepoImplementation(profileApi, AppDataDependencyInjector.ioScheduler)
    static let profileRepository = ProfileRepositoryImplementation(profileApiRepository,
                                                                   AppDataDependencyInjector.ioScheduler)
}
