import Swift
import Moya

class AuthDataDependencyInjector {
    
    private static let authApi = MoyaProvider<AuthApi>(plugins:
        AppDataDependencyInjector.moyaPlugins).rx
    private static let authApiRepository =
        AuthApiRepoImplementation(authApi,
                                  AppDataDependencyInjector.clientSecretKey,
                                  AppDataDependencyInjector.ioScheduler)
    static let authRepository =
        AuthRepoImplementation(AppDataDependencyInjector.authStorageRepository, authApiRepository)
}

