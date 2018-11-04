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

    func test_register() {
        //Register cannot be tested with Hippolyte library because it doesn't suppor .PATCH method
    }

    func test_confirm_email() {
        ScenarioMaker(self)
            .given_an_api_repo()
            .given_an_stubbed_network_call_for_confirm_email("KT")
            .when_confirm_email("KT")
            .then_should_return_inprogress_and_result_success()
    }

    class ScenarioMaker {
        
        var authApiRepo: AuthApiRepository!
        var clientSecretKey: String!
        var testCase: XCTestCase!
        var resultObservable: Observable<Result<AuthToken>>!
        var resultBoolObservable: Observable<Result<Bool>>!

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

        func given_an_stubbed_network_call_for_confirm_email(_ token: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                                          AppDataDependencyInjector.apiUrl + "/people/me/email-confirmation",
                                          .POST, nil, 204, "confirmation_token=" + token)
            return self
        }

        func when_get_person_invitation() -> ScenarioMaker {
            resultObservable = authApiRepo.getPersonInvitation()
            return self
        }
        
        func when_ask_login_email(_ email: String) -> ScenarioMaker {
            resultBoolObservable = authApiRepo.askLoginEmail(email)
            return self
        }
        
        func when_login(_ token: String) -> ScenarioMaker {
            resultObservable = authApiRepo.login(token)
            return self
        }

        func when_confirm_email(_ token: String) -> ScenarioMaker {
            resultBoolObservable = authApiRepo.confirmEmail(token)
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
                let result = try resultBoolObservable.toBlocking().toArray()
                assert (result[0] == Result(.inProgress))
                assert(result[1] == Result(.success, data: true))
            } catch { assertionFailure() }
            return self
        }
    }
}

class AuthApiRepoMock: AuthApiRepository {

    var authToken: AuthToken!
    var askLoginEmailResult: Result<Bool>!
    var askLoginEmailCalls = [String]()
    var loginCalls = [String]()
    var loginResults = [String:Result<AuthToken>]()
    var registerCalls = [(String, String)]()
    var registerResults = [Result<Bool>]()
    var confirmEmailCalls = [String]()
    var confirmEmailResults = [Result<Bool>]()

    func getPersonInvitation() -> Observable<Result<AuthToken>> {
        return Observable.just(Result(.success, data: authToken))
    }

    func askLoginEmail(_ email: String) -> Observable<Result<Bool>> {
        askLoginEmailCalls.append(email)
        return Observable.just(askLoginEmailResult)
    }

    func login(_ token: String) -> Observable<Result<AuthToken>> {
        loginCalls.append(token)
        return Observable.just(loginResults[token]!)
    }

    func register(_ email: String, _ username: String) -> Observable<Result<Bool>> {
        registerCalls.append((email, username))
        return Observable.from(registerResults)
    }

    func confirmEmail(_ confirmationToken: String) -> Observable<Result<Bool>> {
        confirmEmailCalls.append(confirmationToken)
        return Observable.from(confirmEmailResults)
    }
}
