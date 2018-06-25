import Foundation
import Moya

enum ExperienceApi {
    case searchExperiences
    case paginate(String)
}

// MARK: - TargetType Protocol Implementation
extension ExperienceApi: TargetType {
    var baseURL: URL {
        switch self {
        case .searchExperiences:
            return URL(string: AppDataDependencyInjector.apiUrl)!
        case .paginate(let url):
            return URL(string: url)!
        }
    }
    var path: String {
        switch self {
        case .searchExperiences:
            return "/experiences/search"
        case .paginate(_):
            return ""
        }
    }
    var method: Moya.Method {
        switch self {
        case .searchExperiences, .paginate(_):
            return .get
        }
    }
    var task: Task {
        switch self {
        case .searchExperiences, .paginate(_):
            return .requestPlain
        }
    }
    var sampleData: Data {
        let results = String(stringInterpolation: "{\"results\": [",
                      "{\"id\": \"8\",",
                      "\"title\": \"Barcelona\",",
                      "\"description\": \"Live bcn!\",",
                      "\"picture\": null,",
                      "\"isMine\": false,",
                      "\"isSaved\": false,",
                      "\"authorUsername\": \"jordi\",",
                      "\"savesCount\": 8,",
                      "}]").utf8Encoded
        switch self {
        case .searchExperiences, .paginate(_):
            return results
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
