import ObjectMapper

struct LittlePictureMapper: Mappable {
    
    var tinyUrl: String!
    var smallUrl: String!
    var mediumUrl: String!
    var picture: LittlePicture!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        tinyUrl <- map["tiny_url"]
        smallUrl <- map["small_url"]
        mediumUrl <- map["medium_url"]
        picture = LittlePicture(tinyUrl: tinyUrl, smallUrl: smallUrl, mediumUrl: mediumUrl)
    }
    
    func toDomain() -> LittlePicture {
        return picture
    }
}
