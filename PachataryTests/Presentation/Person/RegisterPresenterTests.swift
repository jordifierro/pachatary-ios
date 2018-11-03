import XCTest
import RxSwift
@testable import Pachatary

class RegisterPresenterTests: XCTestCase {

    func test_on_inprogress_disables_button() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.inProgress))
            .when_register(email: "a", username: "u")
            .then_should_disable_button()
            .then_should_show_loader(true)
    }

    func test_on_error_enables_button_and_shows_response_error() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.error, error:
                .clientException(source: "username", code: "wrong_size",
                                 message: "Username must be between 1 and 20 chars")))
            .when_register(email: "a", username: "u")
            .then_should_enable_button()
            .then_should_show_loader(false)
            .then_should_show_error("Username must be between 1 and 20 chars")
    }

    func test_on_success_shows_success_message() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.success))
            .when_register(email: "a", username: "u")
            .then_should_show_success_message()
            .then_should_enable_button()
            .then_should_show_loader(false)
    }

    func test_on_empty_email_shows_empty_email_error() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.success))
            .when_register(email: "", username: "u")
            .then_should_show_error("Email cannot be empty")
    }

    func test_on_empty_username_shows_empty_username_error() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.success))
            .when_register(email: "e", username: "")
            .then_should_show_error("Username cannot be empty")
    }

    class ScenarioMaker {
        let mockView = RegisterViewMock()
        let mockAuthRepo = AuthRepoMock()
        var presenter: RegisterPresenter!

        init() {
            presenter = RegisterPresenter(mockAuthRepo, MainScheduler.instance, mockView)
        }

        func given_an_auth_repo_that_returns(_ result: Result<Bool>) -> ScenarioMaker {
            mockAuthRepo.registerResults = [result]
            return self
        }

        func when_register(email: String, username: String) -> ScenarioMaker {
            presenter.registerClick(email, username)
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
        func then_should_show_error(_ message: String) -> ScenarioMaker {
            assert(mockView.showErrorCalls == [message])
            return self
        }

        @discardableResult
        func then_should_show_loader(_ visibility: Bool) -> ScenarioMaker {
            assert(mockView.showLoaderCalls == [visibility])
            return self
        }
    }
}

class RegisterViewMock: RegisterView {

    var enableButtonCalls = 0
    var disableButtonCalls = 0
    var showSuccessMessageCalls = 0
    var showErrorCalls = [String]()
    var showEmptyEmailErrorCalls = 0
    var showLoaderCalls = [Bool]()

    func enableButton() { enableButtonCalls += 1 }
    func disableButton() { disableButtonCalls += 1 }
    func showSuccessMessage() { showSuccessMessageCalls += 1 }
    func showLoader(_ visibility: Bool) { showLoaderCalls.append(visibility) }
    func showError(message: String) { showErrorCalls.append(message) }


}
