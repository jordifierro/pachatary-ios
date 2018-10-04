import Swift

struct Profile: Equatable {
    
    let username: String
    let bio: String
    let picture: LittlePicture?
    let isMe: Bool

    init(username: String, bio: String, picture: LittlePicture?, isMe: Bool) {
        self.username = username
        self.bio = bio
        self.picture = picture
        self.isMe = isMe
    }
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.username == rhs.username &&
            lhs.bio == rhs.bio &&
            lhs.picture == rhs.picture &&
            lhs.isMe == rhs.isMe
    }
}
