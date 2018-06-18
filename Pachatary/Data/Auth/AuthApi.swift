import Foundation
import Moya

enum AuthApi {
    case createPerson(clientSecretKey: String)
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
        }
    }
    var method: Moya.Method {
        switch self {
        case .createPerson:
            return .post
        }
    }
    var task: Task {
        switch self {
        case let .createPerson(clientSecretKey):
            return .requestParameters(parameters: ["client_secret_key": clientSecretKey],
                                      encoding: URLEncoding.default)
        }
    }
    var sampleData: Data {
        switch self {
        case .createPerson:
            return String(stringInterpolation:
                  "{\"access_token\": \"A_TK\",", "\"refresh_token\": \"R_TK\"}").utf8Encoded
        }
    }
    var headers: [String : String]? {
        return [:]
    }
}
