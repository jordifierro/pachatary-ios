import ObjectMapper

struct ExperienceListMapper: Mappable {
    
    var experienceMappers: [ExperienceMapper]!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        experienceMappers <- map["results"]
    }
    
    func toDomain() -> [Experience] {
        var experiences = [Experience]()
        for mapper in experienceMappers {
            experiences.append(mapper.toDomain())
        }
        return experiences
    }
}



