import XCTest
import RxSwift
@testable import Pachatary

class ProfileRepositoryTests: XCTestCase {
    
    func test_cache_and_retrieve_profile() {
        ScenarioMaker()
            .given_cached_profile(Mock.profile("a"))
            .given_cached_profile(Mock.profile("e"))
            .given_cached_profile(Mock.profile("i"))
            .when_get_profile("a")
            .then_should_return_profile(Mock.profile("a"))
    }
    
    func test_caches_latest() {
        ScenarioMaker()
            .given_cached_profile(Mock.profile("a", bio: "1"))
            .given_cached_profile(Mock.profile("a", bio: "2"))
            .when_get_profile("a")
            .then_should_return_profile(Mock.profile("a", bio: "2"))
    }
    
    class ScenarioMaker {
        
        let repo: ProfileRepository
        
        var profileResult: Profile!
        
        init() {
            repo = ProfileRepositoryImplementation()
        }
        
        func given_cached_profile(_ profile: Profile) -> ScenarioMaker {
            repo.cache(profile)
            return self
        }
        
        func when_get_profile(_ username: String) -> ScenarioMaker {
            try! profileResult = repo.profile(username).toBlocking().first()?.data!
            return self
        }
        
        @discardableResult
        func then_should_return_profile(_ profile: Profile) -> ScenarioMaker {
            assert(profile == profileResult)
            return self
        }
    }
}

class ProfileRepositoryMock: ProfileRepository {
    
    var profileResult = [String:Observable<Result<Profile>>]()
    var cacheCalls = [Profile]()
    
    func cache(_ profile: Profile) {
        cacheCalls.append(profile)
    }
    
    func profile(_ username: String) -> Observable<Result<Profile>> {
        return profileResult[username]!
    }
}
