import ObjectMapper

struct PaginatedListResultMapper<T: ToDomainMapper>: ToResultMapper {

    typealias domainType = [T.domainType]
    
    var mappers: [T]!
    var nextUrl: String!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        mappers <- map["results"]
        nextUrl <- map["next_url"]
    }
    
    func toDomain() -> [T.domainType] {
        var entities = [T.domainType]()
        for mapper in mappers { entities.append(mapper.toDomain()) }
        return entities
    }
    
    func toResult() -> Result<[T.domainType]> {
        return Result(.success, data: toDomain(), nextUrl: nextUrl)
    }
}



