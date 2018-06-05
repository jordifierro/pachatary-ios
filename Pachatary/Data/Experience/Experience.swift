import Swift

struct Experience: Equatable {
    
    let id: String
    let title: String
    let description: String
    let picture: Picture?
    let isMine: Bool
    let isSaved: Bool
    let authorUsername: String
    let savesCount: Int
    
    init(id: String, title: String, description: String, picture: Picture?,
         isMine: Bool, isSaved: Bool, authorUsername: String, savesCount: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.picture = picture
        self.isMine = isMine
        self.isSaved = isSaved
        self.authorUsername = authorUsername
        self.savesCount = savesCount
    }
    
    static func == (lhs: Experience, rhs: Experience) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.picture == rhs.picture &&
            lhs.isMine == rhs.isMine &&
            lhs.isSaved == rhs.isSaved &&
            lhs.authorUsername == rhs.authorUsername &&
            lhs.savesCount == rhs.savesCount
    }
}
