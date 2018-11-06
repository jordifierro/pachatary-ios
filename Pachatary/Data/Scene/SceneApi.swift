import Foundation
import Moya

enum SceneApi {
    case experienceScenes(String)
    case create(experienceId: String, title: String, description: String,
                latitude: Double, longitude: Double)
    case uploadPicture(sceneId: String, picture: UIImage)
    case edit(sceneId: String,
              title: String, description: String,
              latitude: Double, longitude: Double)
}

// MARK: - TargetType Protocol Implementation
extension SceneApi: TargetType {
    var baseURL: URL {
        return URL(string: AppDataDependencyInjector.apiUrl)!
    }
    var path: String {
        switch self {
        case .experienceScenes, .create:
            return "/scenes/"
        case .uploadPicture(let sceneId, _):
            return "/scenes/" + sceneId + "/picture"
        case .edit(let sceneId, _, _, _, _):
            return "/scenes/" + sceneId
        }
    }
    var method: Moya.Method {
        switch self {
        case .experienceScenes:
            return .get
        case .create, .uploadPicture:
            return .post
        case .edit:
            return .patch
        }
    }
    var task: Task {
        switch self {
        case .experienceScenes(let experienceId):
            return .requestParameters(parameters: ["experience": experienceId],
                                      encoding: URLEncoding.default)
        case .create(let experienceId, let title, let description, let latitude, let longitude):
            return .requestParameters(parameters: ["experience_id": experienceId,
                                                   "title": title,
                                                   "description": description,
                                                   "latitude": latitude,
                                                   "longitude": longitude],
                                      encoding: URLEncoding.default)
        case .edit(_, let title, let description, let latitude, let longitude):
            return .requestParameters(parameters: ["title": title,
                                                   "description": description,
                                                   "latitude": latitude,
                                                   "longitude": longitude],
                                      encoding: URLEncoding.default)
        case .uploadPicture(_, let picture):
            let pictureData = MultipartFormData(provider: .data(UIImageJPEGRepresentation(picture, 1)!),
                                                name: "picture",  fileName: "photo.jpg", mimeType: "image/jpeg")
            return .uploadMultipart([pictureData])
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
        let result = String(stringInterpolation: "{",
        "\"id\": \"4\",",
        "\"title\": \"I've been here\",",
        "\"description\": \"\",",
        "\"picture\": null,",
        "\"latitude\": 0.000000,",
        "\"longitude\": 1.000000,",
        "\"experience_id\": \"5\"",
        "}").utf8Encoded
        switch self {
        case .experienceScenes:
            return results
        default:
            return result
        }
    }
    var headers: [String: String]? {
        return [:]
    }
}
