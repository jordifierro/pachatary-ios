import XCTest
import RxSwift
@testable import Pachatary

class LoginPresenterTests: XCTestCase {
    
    func test_on_success_navigates_to_main() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns("a",
                Result(.success, data: AuthToken(accessToken: "A", refreshToken: "R")))
            .when_create_presenter(token: "a")
            .then_should_call_auth_repo_with("a")
            .then_should_navigate_to_main()
    }
    
    class ScenarioMaker {
        let mockView = LoginViewMock()
        let mockAuthRepo = AuthRepoMock()
        var presenter: LoginPresenter!
        
        init() {
            presenter = LoginPresenter(mockAuthRepo, MainScheduler.instance)
            presenter.view = mockView
        }
        
        func given_an_auth_repo_that_returns(_ token: String,
                                             _ result: Result<AuthToken>) -> ScenarioMaker {
            mockAuthRepo.loginResults[token] = result
            return self
        }
        
        func when_create_presenter(token: String) -> ScenarioMaker {
            presenter.token = token
            presenter.create()
            return self
        }
        
        func then_should_call_auth_repo_with(_ token: String) -> ScenarioMaker {
            assert(mockAuthRepo.loginCalls == [token])
            return self
        }
        
        @discardableResult
        func then_should_navigate_to_main() -> ScenarioMaker {
            assert(mockView.navigateToMainCalls == 1)
            return self
        }
    }
}

class LoginViewMock: LoginView {
    
    var navigateToMainCalls = 0
    
    func navigateToMain() { navigateToMainCalls += 1 }
}
