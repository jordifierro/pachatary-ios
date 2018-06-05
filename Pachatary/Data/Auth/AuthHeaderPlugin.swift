import Swift
import Moya

struct AuthHeaderPlugin: PluginType {
    
    let authStorageRepo: AuthStorageRepository!
    
    init(_ authStorageRepo: AuthStorageRepository) {
        self.authStorageRepo = authStorageRepo
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        do { try request.addValue("Token " + authStorageRepo.getPersonCredentials().accessToken,
                                  forHTTPHeaderField: "Authorization")
        } catch { }
        return request
    }
}
