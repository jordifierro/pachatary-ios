import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class AuthApiRepositoryTests: XCTestCase {
    
    func test_get_person_invitation_parses_auth_token_response() {
        ScenarioMaker().buildScenario()
            .given_a_client_secret_key()
            .given_an_api_repo_with_that_client_secret_key()
            .given_an_stubbed_network_call_for_people_post()
            .when_post_create_person()
            .then_should_return_auth_token()
    }
    
    class ScenarioMaker {
        
        var authApiRepo: AuthApiRepository!
        var clientSecretKey: String!
        var testCase: XCTestCase!
        var resultObservable: Observable<AuthToken>!

        init(_ testCase: XCTestCase) {
            self.testCase = testCase
        }
        
        func buildScenario() -> ScenarioMaker {
            return self
        }
        
        func given_a_client_secret_key() -> ScenarioMaker {
            clientSecretKey = "secret"
            return self
        }
        
        func given_an_api_repo_with_that_client_secret_key() -> ScenarioMaker {
            authApiRepo = AuthRepoImplementation(MoyaProvider<AuthApi>().rx, clientSecretKey, MainScheduler.instance)
        }
        
        func given_an_stubbed_network_call_for_people_post() -> ScenarioMaker {
            let url = URL(string: ExperienceDependencyInjector.apiUrl + "/people/")!
            var stub = StubRequest(method: .POST, url: url)
            var response = StubResponse()
            
            var body = Data()
            let path = Bundle(for: type(of: self))
                .path(forResource: "POST_people", ofType: "json")
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
        
        func given_set_person_credentials_with_that_auth_token() -> ScenarioMaker {
            authStorageRepo.setPersonCredentials(authToken: authToken)
            return self
        }
        
        func when_post_create_person() -> ScenarioMaker {
            resultObservable = authApiRepo.getPersonCredentials()
            return self
        }
        
        @discardableResult
        func then_should_return_auth_token() -> ScenarioMaker {
            resultAuhtToken = resultObservable.toBlocking().toArray()[0]
            assert(resultAuhtToken.accessToken == "A_T_12345")
            assert(resultAuhtToken.refreshToken == "R_T_67890")
            return self
        }
    }
}



