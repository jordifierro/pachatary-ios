import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class ProfileApiRepositoryTests: XCTestCase {

    func test_profiles_parses_profiles_response() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_for_profile("username")
            .when_profile_flowable("username")
            .then_should_return_flowable_with_inprogress_and_result_profile()
    }

    class ScenarioMaker {
        let api = MoyaProvider<ProfileApi>().rx
        var repo: ProfileApiRepository!
        var testCase: XCTestCase!
        var resultObservable: Observable<Result<Profile>>!

        init(_ testCase: XCTestCase) {
            self.testCase = testCase
            repo = ProfileApiRepoImplementation(api, MainScheduler.instance)
        }

        func given_an_stubbed_network_call_for_profile(_ username: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                                          AppDataDependencyInjector.apiUrl + "/profiles/" + username,
                                          .GET, "GET_profile")
            return self
        }

        func when_profile_flowable(_ username: String) -> ScenarioMaker {
            resultObservable = repo.profileObservable(username)
            return self
        }

        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_profile() -> ScenarioMaker {
            let expectedProfile = Profile(username: "usr.nam", bio: "user info",
              picture: LittlePicture(tinyUrl: "https://profiles/029d.tiny.jpg",
                                     smallUrl: "https://profiles/029d.small.jpg",
                                     mediumUrl: "https://profiles/029d.medium.jpg"),
              isMe: false)

            do { let result = try resultObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedProfile) == result[1])
            } catch { assertionFailure() }
            return self
        }
    }
}

class ProfileApiRepoMock: ProfileApiRepository {

    var profileObservableResults = [String:Observable<Result<Profile>>]()

    init() {}

    func profileObservable(_ username: String) -> Observable<Result<Profile>> {
        return profileObservableResults[username]!
    }
}
