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

    func test_not_cached_returns_api_call() {
        ScenarioMaker()
            .given_an_api_that_returns_profile("a", Result(.success, data: Mock.profile("a")))
            .when_get_profile("a")
            .then_should_return_profile(Mock.profile("a"))
    }

    func test_not_cached_returns_api_call_and_caches_it() {
        ScenarioMaker()
            .given_an_api_that_returns_profile("a", Result(.success, data: Mock.profile("a")))
            .when_get_profile("a")
            .then_should_return_profile(Mock.profile("a"))
            .given_an_api_that_returns_profile("a",
                Result(.error, error: DataError.noInternetConnection))
            .when_get_profile("a")
            .then_should_return_profile(Mock.profile("a"))
    }

    func test_self_cache_and_retrieve_profile() {
        ScenarioMaker()
            .given_cached_profile(Mock.profile("a"))
            .given_cached_profile(Mock.profile("e", isMe: true))
            .given_cached_profile(Mock.profile("i"))
            .when_get_self_profile()
            .then_should_return_profile(Mock.profile("e", isMe: true))
    }

    func test_self_caches_latest() {
        ScenarioMaker()
            .given_cached_profile(Mock.profile("a", bio: "1", isMe: true))
            .given_cached_profile(Mock.profile("a", bio: "2", isMe: true))
            .when_get_self_profile()
            .then_should_return_profile(Mock.profile("a", bio: "2", isMe: true))
    }

    func test_self_not_cached_returns_api_call() {
        ScenarioMaker()
            .given_an_api_that_returns_profile("self", Result(.success, data: Mock.profile("a", isMe: true)))
            .when_get_self_profile()
            .then_should_return_profile(Mock.profile("a", isMe: true))
    }

    func test_self_not_cached_returns_api_call_and_caches_it() {
        ScenarioMaker()
            .given_an_api_that_returns_profile("self", Result(.success, data: Mock.profile("a", isMe: true)))
            .when_get_self_profile()
            .then_should_return_profile(Mock.profile("a", isMe: true))
            .given_an_api_that_returns_profile("self",
                                               Result(.error, error: DataError.noInternetConnection))
            .when_get_self_profile()
            .then_should_return_profile(Mock.profile("a", isMe: true))
    }

    func test_upload_profile_picture_updates_cache() {
        ScenarioMaker()
            .given_cached_profile(Mock.profile("a", bio: "1"))
            .given_an_api_that_returns_on_upload_profile_picture(
                Result(.success, data: Mock.profile("a", bio: "updated")))
            .when_upload_profile_picture()
            .then_should_return_profile(Mock.profile("a", bio: "updated"))
            .when_get_profile("a")
            .then_should_return_profile(Mock.profile("a", bio: "updated"))
    }

    class ScenarioMaker {
        
        let repo: ProfileRepository
        let mockApiRepo = ProfileApiRepoMock()
        
        var profileResult: Profile!

        init() {
            repo = ProfileRepositoryImplementation(mockApiRepo, MainScheduler.instance)
        }
        
        func given_cached_profile(_ profile: Profile) -> ScenarioMaker {
            repo.cache(profile)
            return self
        }

        func given_an_api_that_returns_profile(_ username: String,
                                              _ result: Result<Profile>) -> ScenarioMaker {
            mockApiRepo.profileObservableResults[username] = Observable.just(result)
            return self
        }

        func given_an_api_that_returns_on_upload_profile_picture(_ result: Result<Profile>) -> ScenarioMaker {
            mockApiRepo.uploadProfilePictureObservableResults = Observable.just(result)
            return self
        }
        
        func when_get_profile(_ username: String) -> ScenarioMaker {
            try! profileResult = repo.profile(username).toBlocking().first()?.data!
            return self
        }

        func when_get_self_profile() -> ScenarioMaker {
            try! profileResult = repo.selfProfile().toBlocking().first()?.data!
            return self
        }

        func when_upload_profile_picture() -> ScenarioMaker {
            try! profileResult = repo.uploadProfilePicture(UIImage()).toBlocking().first()?.data!
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
    var selfProfileResult: Observable<Result<Profile>>!
    var cacheCalls = [Profile]()
    var uploadProfilePictureResult: Observable<Result<Profile>>!
    
    func cache(_ profile: Profile) {
        cacheCalls.append(profile)
    }
    
    func profile(_ username: String) -> Observable<Result<Profile>> {
        return profileResult[username]!
    }

    func selfProfile() -> Observable<Result<Profile>> {
        return selfProfileResult!
    }

    func uploadProfilePicture(_ image: UIImage) -> Observable<Result<Profile>> {
        return uploadProfilePictureResult
    }
}
