import Swift
import ObjectMapper

public protocol ToResultMapper: ToDomainMapper {

    func toResult() -> Result<domainType>
}


