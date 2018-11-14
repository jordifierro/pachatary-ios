import XCTest
import RxSwift
@testable import Pachatary

class AuthRepositoryTests: XCTestCase {
    
    func test_has_person_credentials_returns_true_if_credentials_on_storage() {
        ScenarioMaker(self)
            .given_an_storage_repo_that_returns_auth_token()
            .when_has_person_credentials()
            .then_result_should_be(true)
    }
    
    func test_has_person_credentials_returns_false_if_storage_raises_not_logged_error() {
        ScenarioMaker(self)
            .given_an_storage_repo_that_raises_no_logged_error()
            .when_has_person_credentials()
            .then_result_should_be(false)
    }
    
    func test_get_invitation_calls_api_and_stores_result_auth_token() {
        ScenarioMaker(self)
            .given_an_auth_token()
            .given_an_api_repo_that_returns_that_auth_token()
            .when_get_person_credentials()
            .then_result_should_be_auth_token()
            .then_auth_token_should_be_saved_on_storage_repo()
    }
    
    func test_ask_login_email_calls_api_and_returns_response() {
        ScenarioMaker(self)
            .given_an_api_repo_that_returns_when_ask_login_email(Result(.success))
            .when_ask_login_email("email")
            .then_should_call_api_repo_with("email")
            .then_should_return(Result(.success))
    }
    
    func test_login_calls_api_and_saves_authtoken() {
        ScenarioMaker(self)
            .given_an_api_repo_that_returns_when_login("tok",
                Result(.success, data: AuthToken(accessToken: "A", refreshToken: "R")))
            .when_login("tok")
            .then_should_call_api_login("tok")
            .then_should_should_save_on_storage_repo(AuthToken(accessToken: "A", refreshToken: "R"))
            .then_should_should_set_is_register_completed(true)
            .then_should_return_auth_token(
                Result(.success, data: AuthToken(accessToken: "A", refreshToken: "R")))
    }

    func test_is_register_completed_calls_storage_repo() {
        ScenarioMaker(self)
            .given_an_storage_repo_that_returns_is_register_completed(true)
            .when_is_register_completed()
            .then_should_return_bool(true)
    }

    func test_register_return_api_call() {
        ScenarioMaker(self)
            .given_an_api_repo_that_returns_when_register(Result(.success, data: true))
            .when_register("email@", "user.nma")
            .then_should_call_api_register("email@", "user.nma")
            .then_should_return_bool_result(Result(.success, data: true))
    }

    func test_confirm_email_calls_api_and_sets_is_register_completed_to_true() {
        ScenarioMaker(self)
            .given_an_api_repo_that_returns_when_email_confirmation(Result(.success, data: true))
            .when_email_confirmation("kt")
            .then_should_call_api_email_confirmation("kt")
            .then_should_should_set_is_register_completed(true)
            .then_should_return_bool_result(Result(.success, data: true))
    }

    func test_min_version_returns_api_call() {
        ScenarioMaker(self)
            .given_an_api_repo_that_returns_when_min_version(Result(.success, data: 4))
            .when_min_version()
            .then_should_return_int_result(Result(.success, data: 4))
    }

    func test_block_person_returns_api() {
        ScenarioMaker(self)
            .given_an_api_repo_that_returns_when_block_person(Result(.success, data: true))
            .when_block_person("p")
            .then_should_call_api_block_person("p")
            .then_should_return_bool_result(Result(.success, data: true))
            .then_should_call_experience_repo_remove_cached_experiences_from("p")
    }

    class ScenarioMaker {
        let mockApiRepo = AuthApiRepoMock()
        let mockAuthStorageRepo = AuthStorageRepoMock()
        let mockExperienceRepo = ExperienceRepoMock()
        var repo: AuthRepository!
        var testCase: XCTestCase!
        var resultHasPersonCredentials: Bool!
        var authToken: AuthToken!
        var authTokenResult: Result<AuthToken>!
        var askLoginEmailResult: Result<Bool>!
        var resultBool: Bool!
        var resultBoolResult: Result<Bool>!
        var resultIntObservable: Observable<Result<Int>>!

        init(_ testCase: XCTestCase) {
            self.testCase = testCase
            repo = AuthRepoImplementation(mockAuthStorageRepo, mockApiRepo, mockExperienceRepo)
        }
        
        func given_an_storage_repo_that_returns_auth_token() -> ScenarioMaker {
            mockAuthStorageRepo.hasPersonCredentials = true
            return self
        }
        
        func given_an_storage_repo_that_raises_no_logged_error() -> ScenarioMaker {
            mockAuthStorageRepo.hasPersonCredentials = false
            return self
        }

        func given_an_api_repo_that_returns_when_email_confirmation(_ result: Result<Bool>) -> ScenarioMaker {
            mockApiRepo.confirmEmailResults = [result]
            return self
        }

        func given_an_api_repo_that_returns_when_register(_ result: Result<Bool>) -> ScenarioMaker {
            mockApiRepo.registerResults = [result]
            return self
        }

        func given_an_storage_repo_that_returns_is_register_completed(_ isCompleted: Bool) -> ScenarioMaker {
            mockAuthStorageRepo.isRegisterCompletedResult = isCompleted
            return self
        }
        
        func given_an_auth_token() -> ScenarioMaker {
            authToken = AuthToken(accessToken: "asdf", refreshToken: "qwerty")
            return self
        }
        
        func given_an_api_repo_that_returns_that_auth_token() -> ScenarioMaker {
            mockApiRepo.authToken = self.authToken
            return self
        }
        
        func given_an_api_repo_that_returns_when_ask_login_email(_ result: Result<Bool>) -> ScenarioMaker {
            mockApiRepo.askLoginEmailResult = result
            return self
        }
        
        func given_an_api_repo_that_returns_when_login(
            _ token: String, _ result: Result<AuthToken>) -> ScenarioMaker {
            mockApiRepo.loginResults[token] = result
            return self
        }

        func given_an_api_repo_that_returns_when_min_version(_ result: Result<Int>) -> ScenarioMaker {
            mockApiRepo.minVersionResult = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_when_block_person(_ result: Result<Bool>) -> ScenarioMaker {
            mockApiRepo.blockPersonResult = Observable.just(result)
            return self
        }
        
        func when_has_person_credentials() -> ScenarioMaker {
            resultHasPersonCredentials = repo.hasPersonCredentials()
            return self
        }

        func when_is_register_completed() -> ScenarioMaker {
            resultBool = repo.isRegisterCompleted()
            return self
        }

        func when_register(_ email: String, _ username: String) -> ScenarioMaker {
            do { try resultBoolResult = repo.register(email, username).toBlocking().toArray()[0]
            } catch { assertionFailure() }
            return self
        }

        func when_email_confirmation(_ token: String) -> ScenarioMaker {
            do { try resultBoolResult = repo.confirmEmail(token).toBlocking().toArray()[0]
            } catch { assertionFailure() }
            return self
        }
        
        func when_get_person_credentials() -> ScenarioMaker {
            do { try authTokenResult = repo.getPersonInvitation().toBlocking().toArray()[0]
            } catch { assertionFailure() }
            return self
        }
        
        func when_ask_login_email(_ email: String) -> ScenarioMaker {
            do { try askLoginEmailResult = repo.askLoginEmail(email).toBlocking().toArray()[0]
            } catch { assertionFailure() }
            return self
        }
        
        func when_login(_ token: String) -> ScenarioMaker {
            do { try authTokenResult = repo.login(token).toBlocking().toArray()[0] }
            catch { assertionFailure() }
            return self
        }

        func when_block_person(_ username: String) -> ScenarioMaker {
            do { try resultBoolResult = repo.blockPerson(username).toBlocking().toArray()[0] }
            catch { assertionFailure() }
            return self
        }

        func when_min_version() -> ScenarioMaker {
            resultIntObservable = repo.minVersion()
            return self
        }

        @discardableResult
        func then_should_return_int_result(_ result: Result<Int>) -> ScenarioMaker {
            do {
                let intResult = try resultIntObservable.toBlocking().toArray()[0]
                assert(intResult == result)
            }
            catch { assertionFailure() }
            return self
        }
        
        func then_result_should_be_auth_token() -> ScenarioMaker {
            assert(authTokenResult.status == .success)
            assert(authTokenResult.data! == authToken)
            return self
        }
        
        @discardableResult
        func then_auth_token_should_be_saved_on_storage_repo() -> ScenarioMaker {
            assert(mockAuthStorageRepo.savedAuthToken == authToken)
            return self
        }
        
        func then_should_should_save_on_storage_repo(_ authToken: AuthToken) -> ScenarioMaker {
            assert(mockAuthStorageRepo.savedAuthToken == authToken)
            return self
        }
        
        @discardableResult
        func then_result_should_be(_ hasPersonCredentials: Bool) -> ScenarioMaker {
            assert(resultHasPersonCredentials == hasPersonCredentials)
            return self
        }
        
        func then_should_call_api_repo_with(_ email: String) -> ScenarioMaker {
            assert(mockApiRepo.askLoginEmailCalls == [email])
            return self
        }

        func then_should_call_api_register(_ email: String, _ username: String) -> ScenarioMaker {
            assert(mockApiRepo.registerCalls[0].0 == email)
            assert(mockApiRepo.registerCalls[0].1 == username)
            return self
        }

        func then_should_call_api_email_confirmation(_ token: String) -> ScenarioMaker {
            assert(mockApiRepo.confirmEmailCalls == [token])
            return self
        }

        func then_should_should_set_is_register_completed(_ isCompleted: Bool) -> ScenarioMaker {
            assert(mockAuthStorageRepo.settedIsRegisterCompleted == [isCompleted])
            return self
        }
        
        @discardableResult
        func then_should_return(_ result: Result<Bool>) -> ScenarioMaker {
            assert(askLoginEmailResult == result)
            return self
        }
        
        func then_should_call_api_login(_ token: String) -> ScenarioMaker {
            assert(mockApiRepo.loginCalls == [token])
            return self
        }

        func then_should_call_api_block_person(_ username: String) -> ScenarioMaker {
            assert(mockApiRepo.blockPersonCalls == [username])
            return self
        }
        
        @discardableResult
        func then_should_return_auth_token(_ authTokenResult: Result<AuthToken>) -> ScenarioMaker {
            assert(self.authTokenResult == authTokenResult)
            return self
        }

        @discardableResult
        func then_should_return_bool(_ isCompleted: Bool) -> ScenarioMaker {
            assert(resultBool == isCompleted)
            return self
        }

        @discardableResult
        func then_should_return_bool_result(_ result: Result<Bool>) -> ScenarioMaker {
            assert(resultBoolResult == result)
            return self
        }

        @discardableResult
        func then_should_call_experience_repo_remove_cached_experiences_from(_ username: String)
                                                                                -> ScenarioMaker {
            assert(mockExperienceRepo.removeCacheExperienceFromPersonCalls == [username])
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
    var registerResults = [Result<Bool>]()
    var registerCalls = [(String, String)]()
    var isRegisterCompletedResult = false
    var confirmEmailResults = [Result<Bool>]()
    var confirmEmailCalls = [String]()
    var minVersionResult: Observable<Result<Int>>!
    var blockPersonCalls = [String]()
    var blockPersonResult: Observable<Result<Bool>>!

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

    func register(_ email: String, _ username: String) -> Observable<Result<Bool>> {
        registerCalls.append((email, username))
        return Observable.from(registerResults)
    }

    func isRegisterCompleted() -> Bool {
        return isRegisterCompletedResult
    }

    func confirmEmail(_ confirmationToken: String) -> Observable<Result<Bool>> {
        confirmEmailCalls.append(confirmationToken)
        return Observable.from(confirmEmailResults)
    }

    func minVersion() -> Observable<Result<Int>> {
        return minVersionResult
    }

    func blockPerson(_ username: String) -> Observable<Result<Bool>> {
        blockPersonCalls.append(username)
        return blockPersonResult
    }
}
