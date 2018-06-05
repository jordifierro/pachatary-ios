import XCTest
@testable import Pachatary

class AuthStorageRepositoryTests: XCTestCase {
    
    func test_get_and_set_person_credentials() {
        ScenarioMaker().buildScenario()
            .given_an_auth_token()
            .given_set_person_credentials_with_that_auth_token()
            .when_get_person_credentials()
            .then_should_return_that_auth_token()
    }
    
    func test_get_when_no_credentials_should_throw_no_logged_person_error() {
        ScenarioMaker().buildScenario()
            .when_get_person_credentials()
            .then_should_throw_no_logged_person_error()
    }
    
    class ScenarioMaker {
        
        var authStorageRepo: AuthStorageRepository!
        var authToken: AuthToken!
        var error: Error!
        var resultAuthToken: AuthToken!
        
        init() {}
        
        func buildScenario() -> ScenarioMaker {
            
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            authStorageRepo = AuthStorageRepoImplementation()
            return self
        }
        
        func given_an_auth_token() -> ScenarioMaker {
            authToken = AuthToken(accessToken: "a", refreshToken: "r")
            return self
        }
        
        func given_set_person_credentials_with_that_auth_token() -> ScenarioMaker {
            authStorageRepo.setPersonCredentials(authToken: authToken)
            return self
        }
        
        func when_get_person_credentials() -> ScenarioMaker {
            do {
                try resultAuthToken = authStorageRepo.getPersonCredentials()
            } catch let error {
                self.error = error
            }
            return self
        }
        
        @discardableResult
        func then_should_return_that_auth_token() -> ScenarioMaker {
            assert(authToken == resultAuthToken)
            return self
        }
        
        @discardableResult
        func then_should_throw_no_logged_person_error() -> ScenarioMaker {
            assert((self.error as! DataError) == DataError.noLoggedPerson)
            return self
        }
    }
}

