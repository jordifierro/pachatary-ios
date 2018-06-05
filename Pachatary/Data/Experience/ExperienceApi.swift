import Foundation
import Moya

enum ExperienceApi {
    case searchExperiences
}

// MARK: - TargetType Protocol Implementation
extension ExperienceApi: TargetType {
    var baseURL: URL {
        return URL(string: ExperienceDependencyInjector.apiUrl)!
    }
    var path: String {
        switch self {
        case .searchExperiences:
            return "/experiences/search"
        }
    }
    var method: Moya.Method {
        switch self {
        case .searchExperiences:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .searchExperiences:
            return .requestPlain
        }
    }
    var sampleData: Data {
        switch self {
        case .searchExperiences:
            return String(stringInterpolation: "{\"results\": [",
                "{\"id\": \"8\",",
                "\"title\": \"Barcelona\",",
                "\"description\": \"Live bcn!\",",
                "\"picture\": null,",
                "\"isMine\": false,",
                "\"isSaved\": false,",
                "\"authorUsername\": \"jordi\",",
                "\"savesCount\": 8,",
            "}]").utf8Encoded
        }
    }
    var headers: [String: String]? {
        return [:]
    }
}

// MARK: - Helpers
extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
