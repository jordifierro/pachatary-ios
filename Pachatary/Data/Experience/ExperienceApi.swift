import Foundation
import Moya

enum ExperienceApi {
    case search(String, Double?, Double?)
    case saved
    case paginate(String)
    case save(String, Bool)
    case persons(String)
    case translateShareId(String)
    case experience(String)
    case shareUrl(String)
}

// MARK: - TargetType Protocol Implementation
extension ExperienceApi: TargetType {
    var baseURL: URL {
        switch self {
        case .paginate(let url):
            return URL(string: url)!
        default:
            return URL(string: AppDataDependencyInjector.apiUrl)!
        }
    }
    var path: String {
        switch self {
        case .search:
            return "/experiences/search"
        case .saved, .persons:
            return "/experiences/"
        case .paginate:
            return ""
        case .save(let (id, _)):
            return "/experiences/" + id + "/save"
        case .translateShareId(let shareId):
            return "/experiences/" + shareId + "/id"
        case .experience(let id):
            return "/experiences/" + id
        case .shareUrl(let id):
            return "/experiences/" + id + "/share-url"
        }
    }
    var method: Moya.Method {
        switch self {
        case .save(let (_, save)):
            if save { return .post }
            else { return .delete }
        default:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .search(let text, let latitude, let longitude):
            var params: [String: Any] = [:]
            params["word"] = text
            if latitude != nil { params["latitude"] = latitude }
            if longitude != nil { params["longitude"] = longitude }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .saved:
            return .requestParameters(parameters: ["saved": "true"], encoding: URLEncoding.default)
        case .persons(let username):
            return .requestParameters(parameters: ["username": username],
                                      encoding: URLEncoding.default)
        default:
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
        case .save:
            return "".utf8Encoded
        default:
            return results
        }
    }
    var headers: [String: String]? {
        return [:]
    }
}
