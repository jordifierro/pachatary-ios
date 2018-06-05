import ObjectMapper

struct PictureMapper: Mappable {
    
    var smallUrl: String!
    var mediumUrl: String!
    var largeUrl: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        smallUrl <- map["small_url"]
        mediumUrl <- map["medium_url"]
        largeUrl <- map["large_url"]
    }
    
    func toDomain() -> Picture {
        return Picture(smallUrl: smallUrl, mediumUrl: mediumUrl, largeUrl: largeUrl)
    }
}
