import Swift
import ObjectMapper

public protocol ToDomainMapper: Mappable {
    associatedtype domainType: Equatable
    
    func toDomain() -> domainType
}
