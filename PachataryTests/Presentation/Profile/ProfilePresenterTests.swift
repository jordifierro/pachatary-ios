import XCTest
import RxSwift
@testable import Pachatary

class ProfilePresenterTests: XCTestCase {

    func test_on_experiences_response_success_shows_experiences_filtered_by_params() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .given_an_experience_repo_that_returns_for_persons([
                Result(.success, data: [Mock.experience("2"), Mock.experience("3")], params: Request.Params(username: "test")),
                Result(.success, data: [Mock.experience("4"), Mock.experience("5")], params: Request.Params(username: "other"))])
            .given_a_profile_repo_that_returns_on_profile("test", Result(.inProgress))
            .when_create()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
            .then_should_show_experiences([Mock.experience("2"), Mock.experience("3")])
            .then_should_show_loading_experiences(false)
    }

    func test_on_experiences_response_inprogress() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .given_an_experience_repo_that_returns_for_persons([Result(.inProgress, data: [], params: Request.Params(username: "test"))])
            .given_a_profile_repo_that_returns_on_profile("test", Result(.inProgress))
            .when_create()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
            .then_should_show_experiences([])
            .then_should_show_loading_experiences(true)
    }

    func test_on_experiences_response_error() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .given_an_experience_repo_that_returns_for_persons([Result(.error, params: Request.Params(username: "test"), error: DataError.noInternetConnection)])
            .given_a_profile_repo_that_returns_on_profile("test", Result(.inProgress))
            .when_create()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
            .then_should_show_retry()
            .then_should_show_loading_experiences(false)
    }

    func test_on_profile_response_success() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .given_an_experience_repo_that_returns_for_persons([Result(.inProgress)])
            .given_a_profile_repo_that_returns_on_profile("test",
                  Result(.success, data: Mock.profile("test")))
            .when_create()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
            .then_should_show_profile(Mock.profile("test"))
            .then_should_show_loading_profile(false)
    }

    func test_on_profile_response_inprogress() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .given_an_experience_repo_that_returns_for_persons([Result(.inProgress)])
            .given_a_profile_repo_that_returns_on_profile("test", Result(.inProgress))
            .when_create()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
            .then_should_show_loading_profile(true)
    }

    func test_on_profile_response_error() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .given_an_experience_repo_that_returns_for_persons([Result(.inProgress)])
            .given_a_profile_repo_that_returns_on_profile("test",
                                                      Result(.error, error: DataError.notCached))
            .when_create()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
            .then_should_show_retry()
            .then_should_show_loading_profile(false)
    }

    func test_on_retry_get_firsts_experiences() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .when_retry()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
    }

    func test_on_refresh_get_firsts_experiences() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .when_refresh()
            .then_should_call_getfirsts_persons_experiences_with(Request.Params(username: "test"))
    }

    func test_on_last_item_shown_should_call_repo_paginate() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .when_last_item_shown()
            .then_should_call_experience_repo_paginate()
    }

    func test_on_experience_selected_navigates_to_experience_map_with_id() {
        ScenarioMaker()
            .given_a_presenter_with(username: "test")
            .when_experience_click(experienceId: "4")
            .then_view_should_navigate_to_experience_map(with: "4")
    }

    class ScenarioMaker {
        let mockExperienceRepo = ExperienceRepoMock()
        let mockProfileRepo = ProfileRepositoryMock()
        let mockView = ProfileViewMock()
        var presenter: ProfilePresenter!

        init() {}

        func given_a_presenter_with(username: String) -> ScenarioMaker {
            presenter = ProfilePresenter(mockExperienceRepo, mockProfileRepo,
                                         CurrentThreadScheduler.instance, mockView, username)
            return self
        }

        func given_an_experience_repo_that_returns_for_persons(
                                            _ results: [Result<[Experience]>]) -> ScenarioMaker {
                mockExperienceRepo.returnPersonsObservable = Observable.from(results)
                return self
        }

        func given_a_profile_repo_that_returns_on_profile(_ username: String,
                                                          _ result: Result<Profile>) -> ScenarioMaker {
                mockProfileRepo.profileResult[username] = Observable.just(result)
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
        func then_should_call_getfirsts_persons_experiences_with(_ params: Request.Params) -> ScenarioMaker {
            assert(mockExperienceRepo.getFirstsCalls.count == 1)
            assert(mockExperienceRepo.getFirstsCalls[0].0 == .persons)
            assert(mockExperienceRepo.getFirstsCalls[0].1 == params)
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
            assert(experiences == mockView.showExperienceCalls[0])
            return self
        }

        @discardableResult
        func then_should_show_loading_experiences(_ visibility: Bool) -> ScenarioMaker {
            assert(visibility == mockView.showLoadingExperiencesCalls[0])
            return self
        }

        @discardableResult
        func then_should_show_profile(_ profile: Profile) -> ScenarioMaker {
            assert(profile == mockView.showProfileCalls[0])
            return self
        }

        @discardableResult
        func then_should_show_loading_profile(_ visibility: Bool) -> ScenarioMaker {
            assert(visibility == mockView.showLoadingProfileCalls[0])
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
            assert([Kind.persons] == mockExperienceRepo.paginateCalls)
            return self
        }
    }
}

class ProfileViewMock: ProfileView {

    var showExperienceCalls: [[Experience]] = []
    var showProfileCalls: [Profile] = []
    var showLoadingExperiencesCalls: [Bool] = []
    var showLoadingProfileCalls: [Bool] = []
    var showRetryCalls = 0
    var navigateCalls: [String] = []

    func showExperiences(_ experiences: [Experience]) {
        showExperienceCalls.append(experiences)
    }

    func showLoadingExperiences(_ visibility: Bool) {
        showLoadingExperiencesCalls.append(visibility)
    }

    func showProfile(_ profile: Profile) {
        showProfileCalls.append(profile)
    }

    func showLoadingProfile(_ visibility: Bool) {
        showLoadingProfileCalls.append(visibility)
    }

    func showRetry() {
        self.showRetryCalls += 1
    }

    func navigateToExperienceScenes(_ experienceId: String) {
        self.navigateCalls.append(experienceId)
    }
}
