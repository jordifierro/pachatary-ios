import XCTest
import RxSwift
@testable import Pachatary

class AskLoginEmailPresenterTests: XCTestCase {
    
    func test_on_inprogress_disables_button() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.inProgress))
            .when_ask_login(email: "a")
            .then_should_disable_button()
            .then_should_show_loader(true)
    }
    
    func test_on_error_enables_button() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.error, error: .noInternetConnection))
            .when_ask_login(email: "a")
            .then_should_enable_button()
            .then_should_show_loader(false)
            .then_should_show_error()
    }
    
    func test_on_success_finishes_app() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.success))
            .when_ask_login(email: "a")
            .then_should_show_success_message()
            .then_should_enable_button()
            .then_should_show_loader(false)
    }

    func test_on_empty_email_shows_empty_email_error() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.success))
            .when_ask_login(email: "")
            .then_should_show_empty_email_error()
    }

    class ScenarioMaker {
        let mockView = AskLoginEmailViewMock()
        let mockAuthRepo = AuthRepoMock()
        var presenter: AskLoginEmailPresenter!
        
        init() {
            presenter = AskLoginEmailPresenter(mockAuthRepo, MainScheduler.instance)
            presenter.view = mockView
        }
        
        func given_an_auth_repo_that_returns(_ result: Result<Bool>) -> ScenarioMaker {
            mockAuthRepo.askLoginEmailResult = result
            return self
        }
        
        func when_ask_login(email: String) -> ScenarioMaker {
            presenter.onAskClick(email)
            return self
        }
        
        @discardableResult
        func then_should_disable_button() -> ScenarioMaker {
            assert(mockView.disableButtonCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_enable_button() -> ScenarioMaker {
            assert(mockView.enableButtonCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_show_success_message() -> ScenarioMaker {
            assert(mockView.showSuccessMessageCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_empty_email_error() -> ScenarioMaker {
            assert(mockView.showEmptyEmailErrorCalls == 1)
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
    }
}

class AskLoginEmailViewMock: AskLoginEmailView {
    
    var enableButtonCalls = 0
    var disableButtonCalls = 0
    var showSuccessMessageCalls = 0
    var showErrorCalls = 0
    var showEmptyEmailErrorCalls = 0
    var showLoaderCalls = [Bool]()
    
    func enableButton() { enableButtonCalls += 1 }
    func disableButton() { disableButtonCalls += 1 }
    func showSuccessMessage() { showSuccessMessageCalls += 1 }
    func showLoader(_ visibility: Bool) { showLoaderCalls.append(visibility) }
    func showError() { showErrorCalls += 1 }
    func showEmptyEmailError() { showEmptyEmailErrorCalls += 1 }
}
