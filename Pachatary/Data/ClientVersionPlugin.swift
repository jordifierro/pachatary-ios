import Swift
import Moya

struct ClientVersionPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        let build = Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)!
        request.addValue("iOS-" + String(format: "%03d", build), forHTTPHeaderField: "User-Agent")
        return request
    }
}


