import ObjectMapper

struct ExperienceMapper: Mappable {
    
    var experience: Experience!
    var id: String!
    var title: String!
    var description: String!
    var picture: PictureMapper?
    var isMine: Bool!
    var isSaved: Bool!
    var authorUsername: String!
    var savesCount: Int!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
        picture <- map["picture"]
        isMine <- map["is_mine"]
        isSaved <- map["is_saved"]
        authorUsername <- map["author_username"]
        savesCount <- map["saves_count"]
        experience = Experience(id: id, title: title, description: description,
                                picture: picture?.toDomain(),
                                isMine: isMine, isSaved: isSaved,
                                authorUsername: authorUsername, savesCount: savesCount)
    }
    
    func toDomain() -> Experience {
        return experience
    }
}

