import ObjectMapper

struct ExperienceIdMapper: ToDomainMapper {

    typealias domainType = String

    var experienceId: String!

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        experienceId <- map["experience_id"]
    }

    func toDomain() -> String {
        return experienceId
    }
}
