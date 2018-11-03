import XCTest
@testable import Pachatary

class AuthStorageRepositoryTests: XCTestCase {
    
    func test_get_and_set_person_credentials() {
        ScenarioMaker().buildScenario()
            .given_set_person_credentials(AuthToken(accessToken: "AT", refreshToken: "RT"))
            .when_get_person_credentials()
            .then_should_return(AuthToken(accessToken: "AT", refreshToken: "RT"))
    }
    
    func test_get_when_no_credentials_should_throw_no_logged_person_error() {
        ScenarioMaker().buildScenario()
            .when_get_person_credentials()
            .then_should_throw_no_logged_person_error()
    }

    func test_get_and_set_is_register_completed() {
        ScenarioMaker().buildScenario()
            .given_set_is_register_completed(true)
            .when_is_register_completed()
            .then_should_return_bool(true)
            .given_set_is_register_completed(false)
            .when_is_register_completed()
            .then_should_return_bool(false)
    }

    func test_is_register_completed_returns_false_when_not_set() {
        ScenarioMaker().buildScenario()
            .when_is_register_completed()
            .then_should_return_bool(false)
    }

    class ScenarioMaker {
        
        var authStorageRepo: AuthStorageRepository!
        var error: Error!
        var resultAuthToken: AuthToken!
        var resultBool: Bool!
        
        init() {}
        
        func buildScenario() -> ScenarioMaker {
            
            authStorageRepo = AuthStorageRepoImplementation()
            (authStorageRepo as! AuthStorageRepoImplementation).removeAll()
            return self
        }
        
        func given_set_person_credentials(_ authToken: AuthToken) -> ScenarioMaker {
            authStorageRepo.setPersonCredentials(authToken: authToken)
            return self
        }

        func given_set_is_register_completed(_ isCompleted: Bool) -> ScenarioMaker {
            authStorageRepo.setIsRegisterCompleted(isCompleted)
            return self
        }
        
        func when_get_person_credentials() -> ScenarioMaker {
            do { try resultAuthToken = authStorageRepo.getPersonCredentials() }
            catch let error { self.error = error }
            return self
        }

        func when_is_register_completed() -> ScenarioMaker {
            resultBool = authStorageRepo.isRegisterCompleted()
            return self
        }
        
        @discardableResult
        func then_should_return(_ authToken: AuthToken) -> ScenarioMaker {
            assert(authToken == resultAuthToken)
            return self
        }
        
        @discardableResult
        func then_should_throw_no_logged_person_error() -> ScenarioMaker {
            assert((self.error as! DataError) == DataError.noLoggedPerson)
            return self
        }

        @discardableResult
        func then_should_return_bool(_ isCompleted: Bool) -> ScenarioMaker {
            assert(resultBool == isCompleted)
            return self
        }
    }
}

class AuthStorageRepoMock: AuthStorageRepository {

    var hasPersonCredentials: Bool!
    var savedAuthToken: AuthToken!
    var settedIsRegisterCompleted = [Bool]()
    var isRegisterCompletedResult = false

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

    func setIsRegisterCompleted(_ isCompleted: Bool) {
        settedIsRegisterCompleted.append(isCompleted)
    }

    func isRegisterCompleted() -> Bool {
        return isRegisterCompletedResult
    }
}
