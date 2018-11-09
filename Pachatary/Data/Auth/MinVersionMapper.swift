import ObjectMapper

struct MinVersionMapper: ToDomainMapper {

    struct InnerMapper: ToDomainMapper {
        typealias domainType = Int

        var minVersion: Int!

        init?(map: Map) { }

        mutating func mapping(map: Map) {
            minVersion <- map["min_version"]
        }

        func toDomain() -> Int {
            return minVersion
        }
    }

    typealias domainType = Int

    var innerMapper: InnerMapper!

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        innerMapper <- map["ios"]
    }

    func toDomain() -> Int {
        return innerMapper.toDomain()
    }
}
