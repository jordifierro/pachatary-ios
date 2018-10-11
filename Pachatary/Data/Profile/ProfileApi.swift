import Foundation
import Moya

enum ProfileApi {
    case profile(String)
}

// MARK: - TargetType Protocol Implementation
extension ProfileApi: TargetType {
    var baseURL: URL {
        switch self {
        case .profile(_):
            return URL(string: AppDataDependencyInjector.apiUrl)!
        }
    }
    var path: String {
        switch self {
        case .profile(let username):
            return "/profiles/" + username
        }
    }
    var method: Moya.Method {
        switch self {
        case .profile(_):
            return .get
        }
    }
    var task: Task {
        switch self {
        case .profile(_):
            return .requestPlain
        }
    }
    var sampleData: Data {
        let result = String(stringInterpolation: "[",
                             "{",
                             "\"username\": \"5\",",
                             "\"bio\": \"Plaça Mundial\",",
                             "\"picture\": {",
                             "\"tiny_url\": \"https://profiles/37d6.tiny.jpeg\"",
                             "\"small_url\": \"https://profiles/37d6.small.jpeg\",",
                             "\"medium_url\": \"https://profiles/37d6.medium.jpeg\",",
                             "},",
                             "\"is_me\": true",
                             "}").utf8Encoded
        switch self {
        case .profile(_):
            return result
        }
    }
    var headers: [String: String]? {
        return [:]
    }
}
