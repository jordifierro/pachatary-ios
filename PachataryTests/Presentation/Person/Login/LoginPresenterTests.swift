import XCTest
import RxSwift
@testable import Pachatary

class LoginPresenterTests: XCTestCase {

    enum Action {
        case create
        case retry
    }
    
    func test_on_success_navigates_to_main() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_an_auth_repo_that_returns("a",
                    Result(.success, data: AuthToken(accessToken: "A", refreshToken: "R")))
                .when_do_action(action, token: "a")
                .then_should_call_auth_repo_with("a")
                .then_should_navigate_to_main()
        }
    }

    func test_on_inprogress_shows_loader() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_an_auth_repo_that_returns("a", Result(.inProgress))
                .when_do_action(action, token: "a")
                .then_should_call_auth_repo_with("a")
                .then_should_show_loader(true)
        }
    }

    func test_on_error_hides_loader_and_shows_retry() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_an_auth_repo_that_returns("a",
                                                 Result(.error, error: DataError.noInternetConnection))
                .when_do_action(action, token: "a")
                .then_should_call_auth_repo_with("a")
                .then_should_show_loader(false)
                .then_should_show_retry()
        }
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
        
        func when_do_action(_ action: Action, token: String) -> ScenarioMaker {
            presenter.token = token
            switch action {
            case .create:
                presenter.create()
            case .retry:
                presenter.retry()
            }
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
    }
}

class LoginViewMock: LoginView {
    
    var navigateToMainCalls = 0
    var showLoaderCalls = [Bool]()
    var showRetryCalls = 0
    
    func navigateToMain() { navigateToMainCalls += 1 }
    func showRetry() { showRetryCalls += 1 }
    func showLoader(_ visibility: Bool) { showLoaderCalls.append(visibility) }
}
