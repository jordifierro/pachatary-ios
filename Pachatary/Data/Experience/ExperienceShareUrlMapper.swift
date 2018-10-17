import ObjectMapper

struct ExperienceShareUrlMapper: ToDomainMapper {

    typealias domainType = String

    var shareUrl: String!

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        shareUrl <- map["share_url"]
    }

    func toDomain() -> String {
        return shareUrl
    }
}
