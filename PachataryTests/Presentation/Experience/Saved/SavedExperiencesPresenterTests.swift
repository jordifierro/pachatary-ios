import XCTest
import RxSwift
@testable import Pachatary

class SavedExperiencesPresenterTests: XCTestCase {

    func test_on_experiences_response_success() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_for_saved(
                Result(.success, data: [Experience("2"), Experience("3")]))
            .when_create()
            .then_should_show_experiences([Experience("2"), Experience("3")])
            .then_should_show_loader(false)
    }

    func test_on_experiences_response_inprogress() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_for_saved(
                Result(.inProgress, data: [], action: .getFirsts))
            .when_create()
            .then_should_show_experiences([])
            .then_should_show_loader(true)
    }

    func test_on_experiences_response_error() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_for_saved(Result(.error))
            .when_create()
            .then_should_show_loader(false)
            .then_should_show_retry()
    }

    func test_on_retry_get_firsts_experiences() {
        ScenarioMaker()
            .when_retry()
            .then_should_call_get_firsts_kind_saved()
    }

    func test_on_refresh_get_firsts_experiences() {
        ScenarioMaker()
            .when_refresh()
            .then_should_call_get_firsts_kind_saved()
    }

    func test_on_last_item_shown_should_call_repo_paginate() {
        ScenarioMaker()
            .when_last_item_shown()
            .then_should_call_experience_repo_paginate()
    }

    func test_on_experience_selected_navigates_to_experience_map_with_id() {
        ScenarioMaker()
            .when_experience_click(experienceId: "4")
            .then_view_should_navigate_to_experience_map(with: "4")
    }

    class ScenarioMaker {
        var experiences: [Experience] = []
        let mockExperienceRepo = ExperienceRepoMock()
        let mockView = SavedExperiencesViewMock()
        var presenter: SavedExperiencesPresenter!

        init() {
            presenter = SavedExperiencesPresenter(mockExperienceRepo,
                                                  CurrentThreadScheduler.instance,
                                                  mockView)
        }

        func given_an_experience_repo_that_returns_for_saved(_ result: Result<[Experience]>)
            -> ScenarioMaker {
                mockExperienceRepo.returnSavedObservable = Observable.just(result)
                return self
        }

        func when_create() -> ScenarioMaker {
            presenter.create()
            return self
        }

        func when_retry() -> ScenarioMaker {
            presenter.retryClick()
            return self
        }

        func when_refresh() -> ScenarioMaker {
            presenter.refresh()
            return self
        }

        func when_last_item_shown() -> ScenarioMaker {
            presenter.lastItemShown()
            return self
        }

        func when_experience_click(experienceId: String) -> ScenarioMaker {
            presenter.experienceClick(experienceId)
            return self
        }

        @discardableResult
        func then_view_should_navigate_to_experience_map(with experienceId: String)
            -> ScenarioMaker {
                assert([experienceId] == mockView.navigateCalls)
                return self
        }

        @discardableResult
        func then_should_show_experiences(_ experiences: [Experience]) -> ScenarioMaker {
            assert(experiences == mockView.showCalls[0])
            return self
        }

        @discardableResult
        func then_should_show_loader(_ visibility: Bool) -> ScenarioMaker {
            assert(visibility == mockView.showLoaderCalls[0])
            return self
        }

        @discardableResult
        func then_should_call_get_firsts_kind_saved() -> ScenarioMaker {
            assert(mockExperienceRepo.getFirstsCalls.count == 1)
            assert(mockExperienceRepo.getFirstsCalls[0].0 == Kind.saved)
            assert(mockExperienceRepo.getFirstsCalls[0].1 == nil)
            return self
        }

        func then_should_not_call_get_firsts() -> ScenarioMaker {
            assert(mockExperienceRepo.getFirstsCalls.count == 0)
            return self
        }

        @discardableResult
        func then_should_show_retry() -> ScenarioMaker {
            assert(mockView.showRetryCalls == 1)
            return self
        }

        @discardableResult
        func then_should_call_experience_repo_paginate() -> ScenarioMaker {
            assert([Kind.saved] == mockExperienceRepo.paginateCalls)
            return self
        }
    }
}

class SavedExperiencesViewMock: SavedExperiencesView {

    var showCalls: [[Experience]] = []
    var showLoaderCalls: [Bool] = []
    var showRetryCalls = 0
    var navigateCalls: [String] = []

    func show(experiences: [Experience]) {
        self.showCalls.append(experiences)
    }

    func showLoader(_ visibility: Bool) {
        self.showLoaderCalls.append(visibility)
    }

    func showRetry() {
        self.showRetryCalls += 1
    }

    func navigateToExperienceScenes(_ experienceId: String) {
        self.navigateCalls.append(experienceId)
    }
}
