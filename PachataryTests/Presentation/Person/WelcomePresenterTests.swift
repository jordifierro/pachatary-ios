import XCTest
import RxSwift
@testable import Pachatary

class WelcomePresenterTests: XCTestCase {
    
    func test_on_login_click_navigates_to_login() {
        ScenarioMaker()
            .when_login_click()
            .then_should_navigate_to_login()
    }

    func test_start_when_result_inprogress_disable_button() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result<AuthToken>(.inProgress))
            .when_start_click()
            .then_should_disable_buttons()
    }

    func test_start_when_result_error_enable_buttons() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result<AuthToken>(error: .noInternetConnection))
            .when_start_click()
            .then_should_enable_buttons()
    }

    func test_start_when_result_success_navigates_to_main() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result<AuthToken>(.success))
            .when_start_click()
            .then_should_navigate_to_main()
    }

    class ScenarioMaker {
        let mockView = WelcomeViewMock()
        let mockAuthRepo = AuthRepoMock()
        var presenter: WelcomePresenter!

        init() {
            presenter = WelcomePresenter(mockAuthRepo, MainScheduler.instance)
            presenter.view = mockView
        }
        
        func given_an_auth_repo_that_returns(_ result: Result<AuthToken>) -> ScenarioMaker {
            mockAuthRepo.getPersonInvitationResult = Observable.just(result)
            return self
        }
        
        func when_login_click() -> ScenarioMaker {
            presenter.onLoginClick()
            return self
        }
        
        func when_start_click() -> ScenarioMaker {
            presenter.onStartClick()
            return self
        }
        
        @discardableResult
        func then_should_navigate_to_login() -> ScenarioMaker {
            assert(mockView.navigateToLoginCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_navigate_to_main() -> ScenarioMaker {
            assert(mockView.navigateToMainCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_disable_buttons() -> ScenarioMaker {
            assert(mockView.disableButtonsCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_enable_buttons() -> ScenarioMaker {
            assert(mockView.enableButtonsCalls == 1)
            return self
        }
    }
}

class WelcomeViewMock: WelcomeView {
    
    var navigateToMainCalls = 0
    var navigateToLoginCalls = 0
    var enableButtonsCalls = 0
    var disableButtonsCalls = 0

    func navigateToMain() { navigateToMainCalls += 1 }
    func navigateToLogin() { navigateToLoginCalls += 1 }
    func enableButtons() { enableButtonsCalls += 1 }
    func disableButtons() { disableButtonsCalls += 1 }
}
