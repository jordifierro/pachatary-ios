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
            .then_should_show_loader(true)
    }

    func test_start_when_result_error_enable_buttons() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(
                Result<AuthToken>(.error, error: .noInternetConnection))
            .when_start_click()
            .then_should_enable_buttons()
            .then_should_show_loader(false)
            .then_should_show_error()
    }

    func test_start_when_result_success_navigates_to_main() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result<AuthToken>(.success))
            .when_start_click()
            .then_should_navigate_to_main()
    }

    func test_on_privacy_policy_click_navigates_to_privacy_policy() {
        ScenarioMaker()
            .when_privacy_policy_click()
            .then_should_navigate_to_privacy_policy()
    }

    func test_on_terms_and_conditions_click_navigates_to_terms_and_conditions() {
        ScenarioMaker()
            .when_terms_and_conditions_click()
            .then_should_navigate_to_terms_and_conditions()
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

        func when_privacy_policy_click() -> ScenarioMaker {
            presenter.onPrivacyPolicyClick()
            return self
        }

        func when_terms_and_conditions_click() -> ScenarioMaker {
            presenter.onTermsAndConditionsClick()
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

        @discardableResult
        func then_should_show_loader(_ visibility: Bool) -> ScenarioMaker {
            assert(mockView.showLoaderCalls == [visibility])
            return self
        }

        @discardableResult
        func then_should_show_error() -> ScenarioMaker {
            assert(mockView.showErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_should_navigate_to_privacy_policy() -> ScenarioMaker {
            assert(mockView.navigateToPrivacyPolicyCalls == 1)
            return self
        }

        @discardableResult
        func then_should_navigate_to_terms_and_conditions() -> ScenarioMaker {
            assert(mockView.navigateToTermsAndConditionsCalls == 1)
            return self
        }
    }
}

class WelcomeViewMock: WelcomeView {
    
    var navigateToMainCalls = 0
    var navigateToLoginCalls = 0
    var navigateToPrivacyPolicyCalls = 0
    var navigateToTermsAndConditionsCalls = 0
    var enableButtonsCalls = 0
    var disableButtonsCalls = 0
    var showLoaderCalls = [Bool]()
    var showErrorCalls = 0

    func navigateToMain() { navigateToMainCalls += 1 }
    func navigateToLogin() { navigateToLoginCalls += 1 }
    func navigateToPrivacyPolicy() { navigateToPrivacyPolicyCalls += 1 }
    func navigateToTermsAndConditions() { navigateToTermsAndConditionsCalls += 1 }
    func enableButtons() { enableButtonsCalls += 1 }
    func disableButtons() { disableButtonsCalls += 1 }
    func showLoader(_ visibility: Bool) { showLoaderCalls.append(visibility) }
    func showError() { showErrorCalls += 1 }
}
