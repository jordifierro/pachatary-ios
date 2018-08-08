import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class AuthApiRepositoryTests: XCTestCase {
    
    func test_get_person_invitation_parses_auth_token_response() {
        ScenarioMaker(self)
            .given_a_client_secret_key()
            .given_an_api_repo_with_that_client_secret_key()
            .given_an_stubbed_network_call_for_people_post()
            .when_get_person_invitation()
            .then_should_return_inprogress_and_result_auth_token()
    }

    func test_ask_login_email() {
        ScenarioMaker(self)
            .given_an_api_repo()
            .given_an_stubbed_network_call_for_people_login_email_post("emailtest")
            .when_ask_login_email("emailtest")
            .then_should_return_inprogress_and_result_success()
    }

    class ScenarioMaker {
        
        var authApiRepo: AuthApiRepository!
        var clientSecretKey: String!
        var testCase: XCTestCase!
        var resultObservable: Observable<Result<AuthToken>>!
        var askLoginEmailResultObservable: Observable<Result<Bool>>!

        init(_ testCase: XCTestCase) {
            self.testCase = testCase
        }

        func given_a_client_secret_key() -> ScenarioMaker {
            clientSecretKey = "secret"
            return self
        }
        
        func given_an_api_repo_with_that_client_secret_key() -> ScenarioMaker {
            authApiRepo = AuthApiRepoImplementation(MoyaProvider<AuthApi>().rx,
                                                    clientSecretKey, MainScheduler.instance)
            return self
        }
        
        func given_an_api_repo() -> ScenarioMaker {
            authApiRepo = AuthApiRepoImplementation(MoyaProvider<AuthApi>().rx,
                                                    "", MainScheduler.instance)
            return self
        }
        
        func given_an_stubbed_network_call_for_people_post() -> ScenarioMaker {
            let url = URL(string: AppDataDependencyInjector.apiUrl + "/people/")!
            let requestBody = ("client_secret_key=" + clientSecretKey).data(using: .utf8)!
            var stub = StubRequest(method: .POST, url: url)
            stub.bodyMatcher = DataMatcher(data: requestBody)
            var response = StubResponse()
            
            var body = Data()
            let path = Bundle(for: type(of: self)).path(forResource: "POST_people", ofType: "json")
            do { body = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe) }
            catch { assertionFailure() }
            
            response.body = body
            stub.response = response
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.start()
            
            let expectation = testCase.expectation(description: "Stubs network call")
            let task = URLSession.shared.dataTask(with: url) { data, response, _ in
                //XCTAssertEqual(data, body)
                expectation.fulfill()
            }
            task.resume()
            
            testCase.wait(for: [expectation], timeout: 1)
            return self
        }
        func given_an_stubbed_network_call_for_people_login_email_post(_ email: String) -> ScenarioMaker {
            let url = URL(string: AppDataDependencyInjector.apiUrl + "/people/me/login-email")!
            let requestBody = ("email=" + email).data(using: .utf8)!
            var stub = StubRequest(method: .POST, url: url)
            stub.bodyMatcher = DataMatcher(data: requestBody)
            var response = StubResponse()
            
            response.body = Data()
            stub.response = response
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.start()
            
            let expectation = testCase.expectation(description: "Stubs network call")
            let task = URLSession.shared.dataTask(with: url) { data, response, _ in
                //XCTAssertEqual(data, Data())
                expectation.fulfill()
            }
            task.resume()
            
            testCase.wait(for: [expectation], timeout: 1)
            return self
        }
        
        func when_get_person_invitation() -> ScenarioMaker {
            resultObservable = authApiRepo.getPersonInvitation()
            return self
        }
        
        func when_ask_login_email(_ email: String) -> ScenarioMaker {
            askLoginEmailResultObservable = authApiRepo.askLoginEmail(email)
            return self
        }
        
        @discardableResult
        func then_should_return_inprogress_and_result_auth_token() -> ScenarioMaker {
            do {
                let result = try resultObservable.toBlocking().toArray()
                assert (result[0] == Result(.inProgress))
                assert(result[1] == Result(.success, data:
                    AuthToken(accessToken: "A_T_12345", refreshToken: "R_T_67890")))
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_return_inprogress_and_result_success() -> ScenarioMaker {
            do {
                let result = try askLoginEmailResultObservable.toBlocking().toArray()
                assert (result[0] == Result(.inProgress))
                assert(result[1] == Result(.success, data: true))
            } catch { assertionFailure() }
            return self
        }
    }
}
