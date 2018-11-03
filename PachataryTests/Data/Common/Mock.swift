import Swift
@testable import Pachatary

class Mock {
    
    static func profile(_ username: String, bio: String = "", isMe: Bool = false) -> Profile {
        return Profile(username: username, bio: bio, picture: nil, isMe: isMe)
    }
    
    static func experience(_ id: String,
                           authorProfile: Profile = profile(""),
                           isSaved: Bool = false,
                           savesCount: Int = 0) -> Experience {
        return Experience(id: id, title: "", description: "", picture: nil,
                          isMine: false, isSaved: isSaved, authorProfile: authorProfile,
                          savesCount: savesCount)
    }

    static func scene(_ id: String) -> Scene {
        return Scene(id: id, title: "", description: "", picture: nil,
                     latitude: 0.0, longitude: 0.0, experienceId: "")
    }
}

