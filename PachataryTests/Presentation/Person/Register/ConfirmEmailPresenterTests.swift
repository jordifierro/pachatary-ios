import XCTest
import RxSwift
@testable import Pachatary

class ConfirmEmailPresenterTests: XCTestCase {

    enum Action {
        case create
        case retry
    }

    func test_on_success_navigates_to_main() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter(confirmationToken: "kt")
                .given_an_auth_repo_that_returns(Result(.success, data: true))
                .when_do_action(action)
                .then_should_call_auth_repo_with("kt")
                .then_should_show_success()
                .then_should_navigate_to_main()
        }
    }

    func test_on_inprogress_shows_loader() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter(confirmationToken: "kt")
                .given_an_auth_repo_that_returns(Result(.inProgress))
                .when_do_action(action)
                .then_should_call_auth_repo_with("kt")
                .then_should_show_loader(true)
        }
    }

    func test_on_client_error_shows_error_and_navigates_to_main() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter(confirmationToken: "kt")
                .given_an_auth_repo_that_returns(Result(.error, error: DataError.clientException(source: "s", code: "c", message: "m")))
                .when_do_action(action)
                .then_should_call_auth_repo_with("kt")
                .then_should_show_error()
                .then_should_navigate_to_main()
        }
    }

    func test_on_error_hides_loader_and_shows_retry() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter(confirmationToken: "kt")
                .given_an_auth_repo_that_returns(Result(.error, error: DataError.noInternetConnection))
                .when_do_action(action)
                .then_should_call_auth_repo_with("kt")
                .then_should_show_loader(false)
                .then_should_show_retry()
        }
    }

    class ScenarioMaker {
        let mockView = ConfirmEmailViewMock()
        let mockAuthRepo = AuthRepoMock()
        var presenter: ConfirmEmailPresenter!

        func given_a_presenter(confirmationToken: String) -> ScenarioMaker {
            presenter = ConfirmEmailPresenter(mockAuthRepo, MainScheduler.instance,
                                              mockView, confirmationToken)
            return self
        }

        func given_an_auth_repo_that_returns(_ result: Result<Bool>) -> ScenarioMaker {
            mockAuthRepo.confirmEmailResults = [result]
            return self
        }

        func when_do_action(_ action: Action) -> ScenarioMaker {
            switch action {
            case .create:
                presenter.create()
            case .retry:
                presenter.retry()
            }
            return self
        }

        func then_should_call_auth_repo_with(_ token: String) -> ScenarioMaker {
            assert(mockAuthRepo.confirmEmailCalls == [token])
            return self
        }

        @discardableResult
        func then_should_navigate_to_main() -> ScenarioMaker {
            assert(mockView.navigateToMainCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_loader(_ visibility: Bool) -> ScenarioMaker {
            assert(mockView.showLoaderCalls == [visibility])
            return self
        }

        @discardableResult
        func then_should_show_retry() -> ScenarioMaker {
            assert(mockView.showRetryCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_success() -> ScenarioMaker {
            assert(mockView.showSuccessCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_error() -> ScenarioMaker {
            assert(mockView.showErrorCalls == 1)
            return self
        }
    }
}

class ConfirmEmailViewMock: ConfirmEmailView {

    var navigateToMainCalls = 0
    var showLoaderCalls = [Bool]()
    var showRetryCalls = 0
    var showSuccessCalls = 0
    var showErrorCalls = 0

    func navigateToMain() { navigateToMainCalls += 1 }
    func showRetry() { showRetryCalls += 1 }
    func showLoader(_ visibility: Bool) { showLoaderCalls.append(visibility) }
    func showSuccess() { showSuccessCalls += 1 }
    func showError() { showErrorCalls += 1 }
}
