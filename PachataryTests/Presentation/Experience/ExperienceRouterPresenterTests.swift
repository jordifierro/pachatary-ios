import XCTest
import RxSwift
@testable import Pachatary

class ExperienceRouterPresenterTests: XCTestCase {

    enum Action {
        case create
        case retry
    }

    func test_already_has_credentials_translates_success_navigates_to_experience() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(true)
                .given_an_experience_repo_that_returns(Result(.success, data: "experience_id"))
                .when(do: action)
                .then_should_navigate_to_experience("experience_id")
        }
    }

    func test_already_has_credentials_translates_inprogress_shows_loader() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(true)
                .given_an_experience_repo_that_returns(Result(.inProgress))
                .when(do: action)
                .then_should_show_loading(true)
        }
    }

    func test_already_has_credentials_translates_error_shows_retry() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(true)
                .given_an_experience_repo_that_returns(
                    Result(.error, error: DataError.noInternetConnection))
                .when(do: action)
                .then_should_show_loading(false)
                .then_should_show_retry()
        }
    }

    func test_no_credentials_inprogress_shows_loading() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(Result(.inProgress))
                .when(do: action)
                .then_should_show_loading(true)
        }
    }

    func test_no_credentials_error_shows_retry_and_hides_loader() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(Result(.error, error: DataError.notCached))
                .when(do: action)
                .then_should_show_loading(false)
                .then_should_show_retry()
        }
    }

    func test_no_credentials_success_translates_share_id_success_navigates_to_experience() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(
                    Result(.success, data: AuthToken(accessToken: "a", refreshToken: "r")))
                .given_an_experience_repo_that_returns(Result(.success, data: "experience_id"))
                .when(do: action)
                .then_should_navigate_to_experience("experience_id")
        }
    }

    func test_no_credentials_success_translates_share_id_inprogress_shows_loader() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(
                    Result(.success, data: AuthToken(accessToken: "a", refreshToken: "r")))
                .given_an_experience_repo_that_returns(Result(.inProgress))
                .when(do: action)
                .then_should_show_loading(true)
        }
    }

    func test_no_credentials_success_translates_share_id_error_shows_retry() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter_with("share_id")
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns(
                    Result(.success, data: AuthToken(accessToken: "a", refreshToken: "r")))
                .given_an_experience_repo_that_returns(
                    Result(.error, error: DataError.noInternetConnection))
                .when(do: action)
                .then_should_show_loading(false)
                .then_should_show_retry()
        }
    }

    class ScenarioMaker {

        let mockAuthRepo = AuthRepoMock()
        let mockExperienceRepo = ExperienceRepoMock()
        let mockView = ExperienceRouterViewMock()
        var presenter: ExperienceRouterPresenter!

        init() {}

        func given_a_presenter_with(_ experienceShareId: String) -> ScenarioMaker {
            presenter = ExperienceRouterPresenter(mockAuthRepo, mockExperienceRepo,
                                                  CurrentThreadScheduler.instance,
                                                  mockView, experienceShareId)
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

        func given_an_experience_repo_that_returns(_ result: Result<String>) -> ScenarioMaker {
            mockExperienceRepo.returnTranslateShareIdObservable = Observable.just(result)
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
        func then_should_navigate_to_experience(_ experienceId: String) -> ScenarioMaker {
            assert(mockView.navigateCalls.count == 1)
            assert(mockView.navigateCalls[0] == experienceId)
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

class ExperienceRouterViewMock: ExperienceRouterView {

    var showLoadingCalls: [Bool] = []
    var showRetryCalls = 0
    var navigateCalls: [String] = []

    func navigateToExperience(_ experienceId: String) {
        navigateCalls.append(experienceId)
    }

    func showLoading(_ visibility: Bool) {
        showLoadingCalls.append(visibility)
    }

    func showRetry() {
        self.showRetryCalls += 1
    }
}
