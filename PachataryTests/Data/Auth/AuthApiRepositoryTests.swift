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

    func test_login_parses_auth_token_response() {
        ScenarioMaker(self)
            .given_an_api_repo()
            .given_an_stubbed_network_call_for_people_login("TK")
            .when_login("TK")
            .then_should_return_inprogress_and_result_auth_token()
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
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                AppDataDependencyInjector.apiUrl + "/people/",
                .POST, "POST_people", 201, "client_secret_key=" + clientSecretKey)
            return self
        }
        
        func given_an_stubbed_network_call_for_people_login(_ token: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                AppDataDependencyInjector.apiUrl + "/people/me/login",
                .POST, "POST_people_me_login", 201, "token=" + token)
            return self
        }
        
        func given_an_stubbed_network_call_for_people_login_email_post(_ email: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                AppDataDependencyInjector.apiUrl + "/people/me/login-email",
                .POST, nil, 201, "email=" + email)
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
        
        func when_login(_ token: String) -> ScenarioMaker {
            resultObservable = authApiRepo.login(token)
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

class AuthRepoMock: AuthRepository {

    var hasPersonCredentialsResult: Bool!
    var getPersonInvitationResult: Observable<Result<AuthToken>>!
    var askLoginEmailResult: Result<Bool>? = nil
    var loginCalls = [String]()
    var loginResults = [String:Result<AuthToken>]()

    func hasPersonCredentials() -> Bool {
        return self.hasPersonCredentialsResult
    }

    func getPersonInvitation() -> Observable<Result<AuthToken>> {
        return getPersonInvitationResult
    }

    func askLoginEmail(_ email: String) -> Observable<Result<Bool>> {
        return Observable.just(askLoginEmailResult!)
    }

    func login(_ token: String) -> Observable<Result<AuthToken>> {
        loginCalls.append(token)
        return Observable.just(loginResults[token]!)
    }
}
