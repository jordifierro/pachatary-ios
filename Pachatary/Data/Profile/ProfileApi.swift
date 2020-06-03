import Foundation
import Moya

enum ProfileApi {
    case profile(String)
    case uploadPicture(picture: UIImage)
    case editProfile(bio: String)
}

// MARK: - TargetType Protocol Implementation
extension ProfileApi: TargetType {
    var baseURL: URL {
        return URL(string: AppDataDependencyInjector.apiUrl)!
    }
    var path: String {
        switch self {
        case .profile(let username):
            return "/profiles/" + username
        case .uploadPicture:
            return "/profiles/me/picture"
        case .editProfile:
            return "/profiles/self"
        }
    }
    var method: Moya.Method {
        switch self {
        case .profile:
            return .get
        case .uploadPicture:
            return .post
        case .editProfile:
            return .patch
        }
    }
    var task: Task {
        switch self {
        case .profile(_):
            return .requestPlain
        case .editProfile(let bio):
            return .requestParameters(parameters: ["bio": bio], encoding: URLEncoding.default)
        case .uploadPicture(let picture):
            let pictureData = MultipartFormData(provider: .data(UIImageJPEGRepresentation(picture, 1)!),
                                                name: "picture",  fileName: "photo.jpg", mimeType: "image/jpeg")
            return .uploadMultipart([pictureData])
        }
    }
    var sampleData: Data {
        let result = """
            [\
                 {\
                     "username": "5",\
                     "bio": "Plaça Mundial",\
                     "picture": {\
                         "tiny_url": "https://profiles/37d6.tiny.jpeg",\
                         "small_url": "https://profiles/37d6.small.jpeg",\
                         "medium_url": "https://profiles/37d6.medium.jpeg",\
                     },\
                     "is_me": true\
                 }\
            ]
            """.utf8Encoded
        return result
    }
    var headers: [String: String]? {
        return [:]
    }
}
