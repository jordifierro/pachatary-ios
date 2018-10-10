import XCTest
import RxSwift
@testable import Pachatary

class ProfileRouterPresenterTests: XCTestCase {

    enum Action {
        case create
        case retry
    }

    func test_already_has_credentials_navigates_to_profile() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with(username: "usr")
                .given_an_auth_repo_with_credentials(true)
                .when(do: action)
                .then_should_navigate_to_profile("usr")
        }
    }

    func test_no_credentials_success_navigates_to_profile() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with(username: "usr")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(
                    Result(.success, data: AuthToken(accessToken: "a", refreshToken: "r")))
                .when(do: action)
                .then_should_navigate_to_profile("usr")
        }
    }

    func test_no_credentials_inprogress_shows_loading() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with(username: "usr")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(Result(.inProgress))
                .when(do: action)
                .then_should_show_loading(true)
        }
    }

    func test_no_credentials_error_shows_retry_and_hides_loader() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with(username: "usr")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(Result(.error, error: DataError.notCached))
                .when(do: action)
                .then_should_show_loading(false)
                .then_should_show_retry()
        }
    }

    class ScenarioMaker {

        let mockAuthRepo = AuthRepoMock()
        let mockView = ProfileRouterViewMock()
        var presenter: ProfileRouterPresenter!

        init() {}

        func given_a_presenter_with(username: String) -> ScenarioMaker {
            presenter = ProfileRouterPresenter(mockAuthRepo, CurrentThreadScheduler.instance,
                                               mockView, username)
            return self
        }

        func given_an_auth_repo_with_credentials(_ hasCredentials: Bool) -> ScenarioMaker {
            mockAuthRepo.hasPersonCredentialsResult = hasCredentials
            return self
        }

        func given_an_auth_repo_that_returns(_ result: Result<AuthToken>) -> ScenarioMaker {
            mockAuthRepo.getPersonInvitationResult = Observable.just(result)
            return self
        }

        func when(do action: Action) -> ScenarioMaker {
            switch action {
            case .create:
                presenter.create()
            case .retry:
                presenter.retry()
            }
            return self
        }

        @discardableResult
        func then_should_navigate_to_profile(_ username: String) -> ScenarioMaker {
            assert(mockView.navigateCalls.count == 1)
            assert(mockView.navigateCalls[0] == username)
            return self
        }

        @discardableResult
        func then_should_show_loading(_ visible: Bool) -> ScenarioMaker {
            assert(mockView.showLoadingCalls.count == 1)
            assert(mockView.showLoadingCalls[0] == visible)
            return self
        }

        @discardableResult
        func then_should_show_retry() -> ScenarioMaker {
            assert(mockView.showRetryCalls == 1)
            return self
        }
    }
}

class ProfileRouterViewMock: ProfileRouterView {

    var showLoadingCalls: [Bool] = []
    var showRetryCalls = 0
    var navigateCalls: [String] = []

    func navigateToProfile(_ username: String) {
        navigateCalls.append(username)
    }

    func showLoading(_ visibility: Bool) {
        showLoadingCalls.append(visibility)
    }

    func showRetry() {
        self.showRetryCalls += 1
    }
}
