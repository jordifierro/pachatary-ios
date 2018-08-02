import Swift

struct Experience: Equatable, Identifiable {
    
    let id: String
    let title: String
    let description: String
    let picture: BigPicture?
    let isMine: Bool
    let isSaved: Bool
    let authorProfile: Profile
    let savesCount: Int
    
    init(_ id: String) {
        self.id = id
        self.title = ""
        self.description = ""
        self.picture = nil
        self.isMine = false
        self.isSaved = false
        self.authorProfile = Profile(username: "", bio: "", picture: nil, isMe: false)
        self.savesCount = 0
    }
    
    init(id: String, title: String, description: String, picture: BigPicture?,
         isMine: Bool, isSaved: Bool, authorProfile: Profile, savesCount: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.picture = picture
        self.isMine = isMine
        self.isSaved = isSaved
        self.authorProfile = authorProfile
        self.savesCount = savesCount
    }
    
    static func == (lhs: Experience, rhs: Experience) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.picture == rhs.picture &&
            lhs.isMine == rhs.isMine &&
            lhs.isSaved == rhs.isSaved &&
            lhs.authorProfile == rhs.authorProfile &&
            lhs.savesCount == rhs.savesCount
    }
    
    func builder() -> Builder {
        return Builder(self)
    }
    
    class Builder {
        
        var id: String
        var title: String
        var description: String
        var picture: BigPicture?
        var isMine: Bool
        var isSaved: Bool
        var authorProfile: Profile
        var savesCount: Int
        
        init(_ experience: Experience) {
            self.id = experience.id
            self.title = experience.title
            self.description = experience.description
            self.picture = experience.picture
            self.isMine = experience.isMine
            self.isSaved = experience.isSaved
            self.authorProfile = experience.authorProfile
            self.savesCount = experience.savesCount
        }
        
        func isSaved(_ isSaved: Bool) -> Builder {
            self.isSaved = isSaved
            return self
        }
        
        func savesCount(_ savesCount: Int) -> Builder {
            self.savesCount = savesCount
            return self
        }
 
        func build() -> Experience {
            return Experience(id: self.id, title: self.title, description: self.description,
                              picture: self.picture, isMine: self.isMine, isSaved: self.isSaved,
                              authorProfile: self.authorProfile, savesCount: self.savesCount)
        }
    }
}
