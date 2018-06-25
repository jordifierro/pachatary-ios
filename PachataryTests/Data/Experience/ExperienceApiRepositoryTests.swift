import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class ExperienceApiRepositoryTests: XCTestCase {
    
    func test_get_experiences_search_parses_experiences_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_search()
            .when_experiences_flowable()
            .then_should_return_flowable_with_inprogress_and_result_experiences()
    }
    
    func test_paginate_experiences_parses_experiences_response() {
        ScenarioMaker(self).buildScenario()
            .given_a_pagination_url()
            .given_an_stubbed_network_call_for_pagination()
            .when_paginate_experiences_flowable()
            .then_should_return_flowable_with_inprogress_and_result_experiences()
    }
    
    class ScenarioMaker {
        let api = MoyaProvider<ExperienceApi>().rx
        var repo: ExperienceApiRepository!
        var testCase: XCTestCase!
        var resultObservable: Observable<Result<[Experience]>>!
        var paginationUrl = ""
        
        init(_ testCase: XCTestCase) {
            self.testCase = testCase
        }

        func buildScenario() -> ScenarioMaker {
            repo = ExperienceApiRepoImplementation(api, MainScheduler.instance)
            return self
        }
        
        func given_a_pagination_url() -> ScenarioMaker {
            paginationUrl = "http://domain/path?query=some"
            return self
        }
        
        func given_an_stubbed_network_call_for_search() -> ScenarioMaker {
            let url = URL(string: AppDataDependencyInjector.apiUrl + "/experiences/search")!
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
        
        func given_an_stubbed_network_call_for_pagination() -> ScenarioMaker {
            let url = URL(string: self.paginationUrl)!
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
            resultObservable = repo.exploreExperiencesObservable()
            return self
        }
        
        func when_paginate_experiences_flowable() -> ScenarioMaker {
            resultObservable = repo.paginateExperiences(paginationUrl)
            return self
        }
        
        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_experiences() -> ScenarioMaker {
            let expectedExperiences = [
                Experience( id: "3", title: "Magic Castle of Lost Swamps",
                    description: "Don't even try to go there!", picture: nil, isMine: true,
                    isSaved: false, authorUsername: "da_usr", savesCount: 5),
                Experience( id: "2", title: "Baboóon", description: "Mystical place...",
                    picture: Picture(smallUrl: "https://experiences/8c29.small.jpg",
                                     mediumUrl: "https://experiences/8c29.medium.jpg",
                                     largeUrl: "https://experiences/8c29.large.jpg"),
                    isMine: false, isSaved: true, authorUsername: "usr.nam", savesCount: 32)]
            let expectedNextUrl = "https://base_url/experiences/?mine=false&saved=false&limit=2&offset=2"
            
            do { let result = try resultObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedExperiences, nextUrl: expectedNextUrl) == result[1])
            } catch { assertionFailure() }
            return self
        }
    }
}
