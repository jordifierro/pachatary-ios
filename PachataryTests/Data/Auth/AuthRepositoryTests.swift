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
    
    class ScenarioMaker {
        let mockApiRepo = AuthApiRepoMock()
        let mockAuthStorageRepo = AuthStorageRepoMock()
        var repo: AuthRepository!
        var testCase: XCTestCase!
        var resultHasPersonCredentials: Bool!
        var authToken: AuthToken!
        var authTokenResult: Result<AuthToken>!

        init(_ testCase: XCTestCase) {
            self.testCase = testCase
            repo = AuthRepoImplementation(mockAuthStorageRepo, mockApiRepo)
        }
        
        func given_an_storage_repo_that_returns_auth_token() -> ScenarioMaker {
            mockAuthStorageRepo.hasPersonCredentials = true
            return self
        }
        
        func given_an_storage_repo_that_raises_no_logged_error() -> ScenarioMaker {
            mockAuthStorageRepo.hasPersonCredentials = false
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
        
        func when_has_person_credentials() -> ScenarioMaker {
            resultHasPersonCredentials = repo.hasPersonCredentials()
            return self
        }
        
        func when_get_person_credentials() -> ScenarioMaker {
            do { try authTokenResult = repo.getPersonInvitation().toBlocking().toArray()[0]
            } catch { assertionFailure() }
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
        
        @discardableResult
        func then_result_should_be(_ hasPersonCredentials: Bool) -> ScenarioMaker {
            assert(resultHasPersonCredentials == hasPersonCredentials)
            return self
        }
    }
}

class AuthStorageRepoMock: AuthStorageRepository {
    
    var hasPersonCredentials: Bool!
    var savedAuthToken: AuthToken!
    
    func getPersonCredentials() throws -> AuthToken {
        if hasPersonCredentials {
            return AuthToken(accessToken: "a", refreshToken: "r")
        }
        else {
            throw DataError.noLoggedPerson
        }
    }
    
    func setPersonCredentials(authToken: AuthToken) {
        savedAuthToken = authToken
    }
}

class AuthApiRepoMock: AuthApiRepository {
    
    var authToken: AuthToken!
    
    func getPersonInvitation() -> Observable<Result<AuthToken>> {
        return Observable.just(Result(.success, data: authToken))
    }
}
