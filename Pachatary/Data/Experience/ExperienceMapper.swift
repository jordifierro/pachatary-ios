import ObjectMapper

struct ExperienceMapper: ToDomainMapper {
    
    typealias domainType = Experience
    
    var experience: Experience!
    var id: String!
    var title: String!
    var description: String!
    var picture: BigPictureMapper?
    var isMine: Bool!
    var isSaved: Bool!
    var authorProfile: ProfileMapper!
    var savesCount: Int!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
        picture <- map["picture"]
        isMine <- map["is_mine"]
        isSaved <- map["is_saved"]
        authorProfile <- map["author_profile"]
        savesCount <- map["saves_count"]
        experience = Experience(id: id, title: title, description: description,
                                picture: picture?.toDomain(), isMine: isMine, isSaved: isSaved,
                                authorProfile: authorProfile.toDomain(), savesCount: savesCount)
    }
    
    func toDomain() -> Experience {
        return experience
    }
}

