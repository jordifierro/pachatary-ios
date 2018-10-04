import Swift
@testable import Pachatary

class Mock {
    
    static func profile(_ username: String, bio: String = "") -> Profile {
        return Profile(username: username, bio: bio, picture: nil, isMe: false)
    }
    
    static func experience(_ id: String, authorProfile: Profile = profile("")) -> Experience {
        return Experience(id: id, title: "", description: "", picture: nil,
                          isMine: false, isSaved: false, authorProfile: authorProfile,
                          savesCount: 0)
    }
}

