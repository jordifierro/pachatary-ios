import ObjectMapper

struct ProfileMapper: Mappable {
    
    var username: String!
    var bio: String!
    var picture: LittlePictureMapper?
    var isMe: Bool!
    var profile: Profile!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        username <- map["username"]
        bio <- map["bio"]
        picture <- map["picture"]
        isMe <- map["is_me"]
        profile = Profile(username: username, bio: bio, picture: picture?.toDomain(), isMe: isMe)
    }
    
    func toDomain() -> Profile {
        return profile
    }
}
