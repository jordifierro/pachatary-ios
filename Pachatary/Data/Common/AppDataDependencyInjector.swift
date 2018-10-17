import Foundation
import RxSwift
import Moya

class AppDataDependencyInjector {
    
#if DEBUG
    static let debug: Bool = true
#else
    static let debug: Bool = false
#endif
    
    private static let apiKeysPath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
    private static let apiKeysDict = NSDictionary(contentsOfFile: apiKeysPath!)
    
    static var apiUrl: String { get {
        if debug { return apiKeysDict!["devApiUrl"] as! String }
        else { return apiKeysDict!["apiUrl"] as! String }
    }}
    static var publicUrl: String { get {
        if debug { return apiKeysDict!["devPublicUrl"] as! String }
        else { return apiKeysDict!["publicUrl"] as! String }
        }}
    static var clientSecretKey: String { get {
        if debug { return apiKeysDict!["devClientSecretKey"] as! String }
        else { return apiKeysDict!["clientSecretKey"] as! String }
    }}
    static var mapboxAccessToken: String { get {
        if debug { return apiKeysDict!["mapboxAccessToken"] as! String }
        else { return apiKeysDict!["mapboxAccessToken"] as! String }
        }}
    static let ioScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    static let authStorageRepository = AuthStorageRepoImplementation()
    private static let authHeaderPlugin = AuthHeaderPlugin(authStorageRepository)
    private static let clientVersionPlugin = ClientVersionPlugin()
    static let moyaPlugins = [authHeaderPlugin, clientVersionPlugin] as [PluginType]
}

