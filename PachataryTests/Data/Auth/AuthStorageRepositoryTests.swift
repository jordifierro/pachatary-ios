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
    
    class ScenarioMaker {
        
        var authStorageRepo: AuthStorageRepository!
        var error: Error!
        var resultAuthToken: AuthToken!
        
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
        
        func when_get_person_credentials() -> ScenarioMaker {
            do { try resultAuthToken = authStorageRepo.getPersonCredentials() }
            catch let error { self.error = error }
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
    }
}
