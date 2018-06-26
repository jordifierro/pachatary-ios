import Swift
import ObjectMapper

struct SingleResultMapper<T: ToDomainMapper>: ToResultMapper {

    typealias domainType = T.domainType
    
    var tMapper: T!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        tMapper <- Map(mappingType: .fromJSON, JSON: ["result": map.JSON])["result"]
    }
    
    func toDomain() -> T.domainType {
        return tMapper!.toDomain()
    }
    
    func toResult() -> Result<T.domainType> {
        return Result(.success, data: toDomain())
    }
}





