import Foundation
import Moya

enum ExperienceApi {
    case searchExperiences(String, Double?, Double?)
    case paginate(String)
    case save(String, Bool)
}

// MARK: - TargetType Protocol Implementation
extension ExperienceApi: TargetType {
    var baseURL: URL {
        switch self {
        case .searchExperiences, .save:
            return URL(string: AppDataDependencyInjector.apiUrl)!
        case .paginate(let url):
            return URL(string: url)!
        }
    }
    var path: String {
        switch self {
        case .searchExperiences:
            return "/experiences/search"
        case .paginate:
            return ""
        case .save(let (id, _)):
            return "/experiences/" + id + "/save"
        }
    }
    var method: Moya.Method {
        switch self {
        case .searchExperiences, .paginate:
            return .get
        case .save(let (_, save)):
            if save { return .post }
            else { return .delete }
        }
    }
    var task: Task {
        switch self {
        case .paginate, .save:
            return .requestPlain
        case .searchExperiences(let text, let latitude, let longitude):
            var params: [String: Any] = [:]
            params["word"] = text
            if latitude != nil { params["latitude"] = latitude }
            if longitude != nil { params["longitude"] = longitude }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
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
        case .searchExperiences, .paginate:
            return results
        case .save:
            return "".utf8Encoded
        }
    }
    var headers: [String: String]? {
        return [:]
    }
}
