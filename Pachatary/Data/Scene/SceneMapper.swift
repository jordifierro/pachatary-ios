import ObjectMapper

struct SceneMapper: ToDomainMapper {
    
    typealias domainType = Scene
    
    var scene: Scene!
    var id: String!
    var title: String!
    var description: String!
    var picture: PictureMapper?
    var latitude: Double!
    var longitude: Double!
    var experienceId: String!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
        picture <- map["picture"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        experienceId <- map["experience_id"]
        scene = Scene(id: id, title: title, description: description,
                      picture: picture?.toDomain(),
                      latitude: latitude, longitude: longitude, experienceId: experienceId)
    }
    
    func toDomain() -> Scene {
        return scene
    }
}



