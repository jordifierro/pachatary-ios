import Foundation
import Moya

enum AuthApi {
    case createPerson(clientSecretKey: String)
    case askLoginEmail(email: String)
    case login(token: String)
    case register(email: String, username: String)
    case confirmEmail(confirmationToken: String)
    case minVersion
    case blockPerson(username: String)
}

// MARK: - TargetType Protocol Implementation
extension AuthApi: TargetType {
    var baseURL: URL {
        return URL(string: AppDataDependencyInjector.apiUrl)!
    }
    var path: String {
        switch self {
        case .minVersion:
            return "/client-versions"
        case .createPerson:
            return "/people/"
        case .askLoginEmail:
            return "/people/me/login-email"
        case .login:
            return "/people/me/login"
        case .register:
            return "/people/me"
        case .confirmEmail:
            return "/people/me/email-confirmation"
        case .blockPerson(let username):
            return "/people/" + username + "/block"
        }
    }
    var method: Moya.Method {
        switch self {
        case .minVersion:
            return .get
        case .createPerson, .askLoginEmail, .login, .confirmEmail, .blockPerson:
            return .post
        case .register:
            return .patch
        }
    }
    var task: Task {
        switch self {
        case .minVersion, .blockPerson:
            return .requestPlain
        case let .createPerson(clientSecretKey):
            return .requestParameters(parameters: ["client_secret_key": clientSecretKey],
                                      encoding: URLEncoding.default)
        case let .askLoginEmail(email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case let .login(token):
            return .requestParameters(parameters: ["token": token], encoding: URLEncoding.default)
        case let .register(email, username):
            return .requestParameters(parameters: ["email": email, "username": username], encoding: URLEncoding.default)
        case let .confirmEmail(confirmationToken):
            return .requestParameters(parameters: ["confirmation_token": confirmationToken],
                                      encoding: URLEncoding.default)
        }
    }
    var sampleData: Data {
        switch self {
        case .createPerson, .login:
            return """
                    {"access_token": "A_TK", "refresh_token": "R_TK"}
                    """.utf8Encoded
        default:
            return "".utf8Encoded
        }
    }
    var headers: [String : String]? {
        return [:]
    }
}
