import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class ExperienceRepositoryTests: XCTestCase {
    
    func test_get_experiences_search_parses_experiences_response() {
        ScenarioMaker().buildScenario(self)
            .given_an_stubbed_network_call()
            .when_experiences_flowable()
            .then_should_return_flowable_that_parses()
    }
    
    class ScenarioMaker {
        let api = MoyaProvider<ExperienceApi>().rx
        var repo: ExperienceRepository!
        var testCase: XCTestCase!
        var resultObservable: Observable<[Experience]>!

        func buildScenario(_ testCase: XCTestCase) -> ScenarioMaker {
            self.testCase = testCase
            repo = ExperienceRepoImplementation(api)
            return self
        }
        
        func given_an_stubbed_network_call() -> ScenarioMaker {
            let url = URL(string: ExperienceDependencyInjector.apiUrl + "/experiences/search")!
            var stub = StubRequest(method: .GET, url: url)
            var response = StubResponse()
            
            var body = Data()
            let path = Bundle(for: type(of: self))
                .path(forResource: "GET_experiences_search", ofType: "json")
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
        
        func when_experiences_flowable() -> ScenarioMaker {
            resultObservable = repo.experiencesObservable()
            return self
        }
        
        @discardableResult
        func then_should_return_flowable_that_parses() -> ScenarioMaker {
            let expectedExperiences = [
                Experience( id: "3", title: "Magic Castle of Lost Swamps",
                    description: "Don't even try to go there!", picture: nil, isMine: true,
                    isSaved: false, authorUsername: "da_usr", savesCount: 5),
                Experience( id: "2", title: "Baboóon", description: "Mystical place...",
                    picture: Picture(smallUrl: "https://experiences/8c29.small.jpg",
                                     mediumUrl: "https://experiences/8c29.medium.jpg",
                                     largeUrl: "https://experiences/8c29.large.jpg"),
                    isMine: false, isSaved: true, authorUsername: "usr.nam", savesCount: 32)]
            
            do { let result = try resultObservable.toBlocking().toArray()
                assert(result.count == 1)
                assert(expectedExperiences == result[0])
            } catch { assertionFailure() }
            return self
        }
    }
}


