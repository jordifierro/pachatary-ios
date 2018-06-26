import Foundation
import Moya

enum SceneApi {
    case experienceScenes(String)
}

// MARK: - TargetType Protocol Implementation
extension SceneApi: TargetType {
    var baseURL: URL {
        switch self {
        case .experienceScenes(_):
            return URL(string: AppDataDependencyInjector.apiUrl)!
        }
    }
    var path: String {
        switch self {
        case .experienceScenes(_):
            return "/scenes/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .experienceScenes(_):
            return .get
        }
    }
    var task: Task {
        switch self {
        case .experienceScenes(let experienceId):
            return .requestParameters(parameters: ["experience": experienceId],
                                      encoding: URLEncoding.default)
        }
    }
    var sampleData: Data {
        let results = String(stringInterpolation: "[",
        "{",
            "\"id\": \"5\",",
            "\"title\": \"Plaça Mundial\",",
            "\"description\": \"World wide square!\",",
            "\"picture\": {",
                "\"small_url\": \"https://scenes/37d6.small.jpeg\",",
                "\"medium_url\": \"https://scenes/37d6.medium.jpeg\",",
                "\"large_url\": \"https://scenes/37d6.large.jpeg\"",
            "},",
            "\"latitude\": 1.000000,",
            "\"longitude\": 2.000000,",
            "\"experience_id\": \"5\"",
            "},",
        "{",
            "\"id\": \"4\",",
            "\"title\": \"I've been here\",",
            "\"description\": \"\",",
            "\"picture\": null,",
            "\"latitude\": 0.000000,",
            "\"longitude\": 1.000000,",
            "\"experience_id\": \"5\"",
            "},",
        "]").utf8Encoded
        switch self {
        case .experienceScenes(_):
            return results
        }
    }
    var headers: [String: String]? {
        return [:]
    }
}
