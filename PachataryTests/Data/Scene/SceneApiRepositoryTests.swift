import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class SceneApiRepositoryTests: XCTestCase {
    
    func test_scenes_parses_scenes_response() {
        ScenarioMaker(self)
            .given_an_experience_id()
            .given_an_stubbed_network_call_for_scenes_experience_id()
            .when_scenes_flowable_with_that_id()
            .then_should_return_flowable_with_inprogress_and_result_scenes()
    }
    
    class ScenarioMaker {
        let api = MoyaProvider<SceneApi>().rx
        var repo: SceneApiRepository!
        var testCase: XCTestCase!
        var resultObservable: Observable<Result<[Scene]>>!
        var paginationUrl = ""
        var experienceId = ""
        
        init(_ testCase: XCTestCase) {
            self.testCase = testCase
            repo = SceneApiRepoImplementation(api, MainScheduler.instance)
        }

        func given_an_experience_id() -> ScenarioMaker {
            self.experienceId = "9"
            return self
        }
        
        func given_an_stubbed_network_call_for_scenes_experience_id() -> ScenarioMaker {
            let url = URL(string: AppDataDependencyInjector.apiUrl +
                                  "/scenes/?experience=" + experienceId)!
            var stub = StubRequest(method: .GET, url: url)
            var response = StubResponse()
            
            var body = Data()
            let path = Bundle(for: type(of: self))
                .path(forResource: "GET_scenes_experience_id", ofType: "json")
            do { body = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe) }
            catch { assertionFailure() }
            
            response.body = body
            stub.response = response
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.start()
            
            let expectation = testCase.expectation(description: "Stubs network call")
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                XCTAssertEqual(data, body)
                expectation.fulfill()
            }
            task.resume()
            
            testCase.wait(for: [expectation], timeout: 1)
            return self
        }

        func when_scenes_flowable_with_that_id() -> ScenarioMaker {
            resultObservable = repo.scenesObservable(experienceId: experienceId)
            return self
        }

        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_scenes() -> ScenarioMaker {
            let expectedScenes = [
                Scene(id: "5",
                      title: "Plaça Mundial",
                      description: "World wide square!",
                      picture: Picture(smallUrl: "https://scenes/37d6.small.jpeg",
                                       mediumUrl: "https://scenes/37d6.medium.jpeg",
                                       largeUrl: "https://scenes/37d6.large.jpeg"),
                      latitude: 1.0,
                      longitude: 2.0,
                      experienceId: "5"),
                Scene(id: "4",
                      title: "I've been here",
                      description: "",
                      picture: nil,
                      latitude: 0.0,
                      longitude: 1.0,
                      experienceId: "5")]

            do { let result = try resultObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedScenes) == result[1])
            } catch { assertionFailure() }
            return self
        }
    }
}
