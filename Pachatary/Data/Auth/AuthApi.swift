import Foundation
import Moya

enum AuthApi {
    case createPerson(clientSecretKey: String)
    case askLoginEmail(email: String)
    case login(token: String)
}

// MARK: - TargetType Protocol Implementation
extension AuthApi: TargetType {
    var baseURL: URL {
        return URL(string: AppDataDependencyInjector.apiUrl)!
    }
    var path: String {
        switch self {
        case .createPerson:
            return "/people/"
        case .askLoginEmail:
            return "/people/me/login-email"
        case .login:
            return "/people/me/login"
        }
    }
    var method: Moya.Method {
        switch self {
        case .createPerson, .askLoginEmail, .login:
            return .post
        }
    }
    var task: Task {
        switch self {
        case let .createPerson(clientSecretKey):
            return .requestParameters(parameters: ["client_secret_key": clientSecretKey],
                                      encoding: URLEncoding.default)
        case let .askLoginEmail(email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case let .login(token):
            return .requestParameters(parameters: ["token": token], encoding: URLEncoding.default)
        }
    }
    var sampleData: Data {
        switch self {
        case .createPerson, .login:
            return String(stringInterpolation:
                  "{\"access_token\": \"A_TK\",", "\"refresh_token\": \"R_TK\"}").utf8Encoded
        case .askLoginEmail:
            return String(stringInterpolation: "").utf8Encoded
        }
    }
    var headers: [String : String]? {
        return [:]
    }
}
