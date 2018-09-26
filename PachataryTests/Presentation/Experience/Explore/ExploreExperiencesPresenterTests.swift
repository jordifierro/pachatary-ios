import XCTest
import RxSwift
@testable import Pachatary

class ExploreExperiencesPresenterTests: XCTestCase {
    
    func test_on_experiences_response_success() {
        ScenarioMaker()
            .given_an_experience(id: "7")
            .given_an_experience(id: "8")
            .given_a_view_that_has_location_permission(false)
            .given_an_experience_repo_that_returns_that_experiences()
            .when_create()
            .then_should_show_experiences()
            .then_should_show_loader(false)
            .then_should_show_pagination_loader(false)
            .then_should_show_retry(false)
            .then_should_show_error(false)
    }

    func test_on_experiences_response_inprogress_getfirsts() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_in_progress(.getFirsts)
            .given_a_view_that_has_location_permission(false)
            .when_create()
            .then_should_show_loader(true)
            .then_should_show_pagination_loader(false)
            .then_should_show_retry(false)
            .then_should_show_error(false)
    }

    func test_on_experiences_response_inprogress_paginate() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_in_progress(.paginate)
            .when_create()
            .then_should_show_loader(false)
            .then_should_show_pagination_loader(true)
            .then_should_show_retry(false)
            .then_should_show_error(false)
    }

    func test_on_experiences_response_error() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_error()
            .given_a_view_that_has_location_permission(false)
            .when_create()
            .then_should_show_loader(false)
            .then_should_show_pagination_loader(false)
            .then_should_show_retry(true)
            .then_should_show_error(true)
    }
    
    func test_on_create_ask_location_if_has_permission() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_error()
            .given_a_view_that_has_location_permission(true)
            .when_create()
            .then_should_ask_location()
    }

    func test_on_create_ask_permission_if_has_not_permission() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_error()
            .given_a_view_that_has_location_permission(false)
            .when_create()
            .then_should_ask_permission()
    }

    func test_on_permission_accepted_asks_last_known_location() {
        ScenarioMaker()
            .when_permission_accepted()
            .then_should_ask_last_known_location()
    }

    func test_on_permission_denied_get_firsts_experiences() {
        ScenarioMaker()
            .when_permission_denied()
            .then_should_call_get_firsts_kind_explore(with: Request.Params())
    }

    func test_on_last_location_found_get_firsts_experiences() {
        ScenarioMaker()
            .when_last_location_found(2.0, -5.9)
            .then_should_call_get_firsts_kind_explore(with: Request.Params(nil, 2.0, -5.9))
    }

    func test_on_last_location_not_found_get_firsts_experiences() {
        ScenarioMaker()
            .when_last_location_not_found()
            .then_should_call_get_firsts_kind_explore(with: Request.Params())
    }

    func test_on_retry_get_firsts_experiences() {
        ScenarioMaker()
            .when_retry()
            .then_should_call_get_firsts_kind_explore(with: Request.Params())
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

    func test_on_search_call_get_firsts_with_word() {
        ScenarioMaker()
            .when_search("nature")
            .then_should_call_get_firsts_kind_explore(with: Request.Params("nature"))
    }

    class ScenarioMaker {
        var experiences: [Experience] = []
        let mockExperienceRepo = ExperienceRepoMock()
        var mockView: ExploreExperiencesViewMock!
        var presenter: ExploreExperiencesPresenter!

        init() {
            mockView = ExploreExperiencesViewMock()
            presenter = ExploreExperiencesPresenter(mockExperienceRepo,
                                                    CurrentThreadScheduler.instance)
            presenter.view = mockView
        }

        func given_a_view_that_has_location_permission(_ hasPermissions: Bool) -> ScenarioMaker {
            mockView.hasLocationPermissionResponse = hasPermissions
            return self
        }

        func given_an_experience(id: String, title: String = "", description: String = "",
                                 picture: BigPicture? = nil, isMine: Bool = false,
                                 isSaved: Bool = false, authorUsername: String = "",
                                 savesCount: Int = 0) -> ScenarioMaker {
            experiences.append(Experience(id: id, title: title, description: description,
                                          picture: picture, isMine: isMine, isSaved: isSaved,
                                          authorProfile: Profile(username: authorUsername, bio: "",
                                                                 picture: nil, isMe: false),
                                          savesCount: savesCount))
            return self
        }
        
        func given_an_experience_repo_that_returns_that_experiences() -> ScenarioMaker {
            mockExperienceRepo.returnExperiences = experiences
            return self
        }
        
        func given_an_experience_repo_that_returns_in_progress(_ action: Request.Action = .getFirsts)
                                                                                -> ScenarioMaker {
            mockExperienceRepo.returnInProgress = true
            mockExperienceRepo.returnAction = action
            return self
        }
        
        func given_an_experience_repo_that_returns_error() -> ScenarioMaker {
            mockExperienceRepo.returnError = DataError.noInternetConnection
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
        
        func when_last_item_shown() -> ScenarioMaker {
            presenter.lastItemShown()
            return self
        }
        
        func when_experience_click(experienceId: String) -> ScenarioMaker {
            presenter.experienceClick(experienceId)
            return self
        }

        func when_search(_ word: String) -> ScenarioMaker {
            presenter.searchClick(word)
            return self
        }

        func when_permission_accepted() -> ScenarioMaker {
            presenter.onPermissionAccepted()
            return self
        }

        func when_permission_denied() -> ScenarioMaker {
            presenter.onPermissionDenied()
            return self
        }

        func when_last_location_found(_ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            presenter.onLastLocationFound(latitude: latitude, longitude: longitude)
            return self
        }

        func when_last_location_not_found() -> ScenarioMaker {
            presenter.onLastLocationNotFound()
            return self
        }

        @discardableResult
        func then_view_should_navigate_to_experience_map(with experienceId: String)
                                                                                  -> ScenarioMaker {
            assert([experienceId] == mockView.navigateCalls)
            return self
        }

        @discardableResult
        func then_should_show_experiences() -> ScenarioMaker {
            assert(experiences == mockView.showCalls[0])
            return self
        }

        func then_should_show_loader(_ visibility: Bool) -> ScenarioMaker {
            assert(visibility == mockView.showLoaderCalls[0])
            return self
        }
        
        func then_should_show_pagination_loader(_ visibility: Bool) -> ScenarioMaker {
            assert(visibility == mockView.showPaginationLoaderCalls[0])
            return self
        }
        
        @discardableResult
        func then_should_call_get_firsts_kind_explore(with params: Request.Params) -> ScenarioMaker {
            assert(mockExperienceRepo.getFirstsCalls.count == 1)
            assert(mockExperienceRepo.getFirstsCalls[0].0 == Kind.explore)
            assert(mockExperienceRepo.getFirstsCalls[0].1 == params)
            return self
        }
        
        func then_should_not_call_get_firsts() -> ScenarioMaker {
            assert(mockExperienceRepo.getFirstsCalls.count == 0)
            return self
        }

        @discardableResult
        func then_should_show_retry(_ visibility: Bool) -> ScenarioMaker {
            assert(visibility == mockView.showRetryCalls[0])
            return self
        }

        @discardableResult
        func then_should_show_error(_ visibility: Bool) -> ScenarioMaker {
            assert(visibility == mockView.showErrorCalls[0])
            return self
        }
        
        @discardableResult
        func then_should_call_experience_repo_paginate() -> ScenarioMaker {
            assert([Kind.explore] == mockExperienceRepo.paginateCalls)
            return self
        }

        @discardableResult
        func then_should_ask_location() -> ScenarioMaker {
            assert(mockView.askLastKnownLocationCalls == 1)
            return self
        }

        @discardableResult
        func then_should_ask_permission() -> ScenarioMaker {
            assert(mockView.askLocationPermissionCalls == 1)
            return self
        }

        @discardableResult
        func then_should_ask_last_known_location() -> ScenarioMaker {
            assert(mockView.askLastKnownLocationCalls == 1)
            return self
        }
    }
}

class ExploreExperiencesViewMock: ExploreExperiencesView {

    var showCalls: [[Experience]] = []
    var showLoaderCalls: [Bool] = []
    var showPaginationLoaderCalls: [Bool] = []
    var showErrorCalls: [Bool] = []
    var showRetryCalls: [Bool] = []
    var navigateCalls: [String] = []
    var hasLocationPermissionResponse = false
    var hasLocationPermissionCalls = 0
    var askLocationPermissionCalls = 0
    var askLastKnownLocationCalls = 0

    func show(experiences: [Experience]) {
        self.showCalls.append(experiences)
    }
    
    func showLoader(_ visibility: Bool) {
        self.showLoaderCalls.append(visibility)
    }
    
    func showPaginationLoader(_ visibility: Bool) {
        self.showPaginationLoaderCalls.append(visibility)
    }
    
    func showError(_ visibility: Bool) {
        self.showErrorCalls.append(visibility)
    }
    
    func showRetry(_ visibility: Bool) {
        self.showRetryCalls.append(visibility)
    }
    
    func navigateToExperienceScenes(_ experienceId: String) {
        self.navigateCalls.append(experienceId)
    }

    func hasLocationPermission() -> Bool {
        hasLocationPermissionCalls += 1
        return hasLocationPermissionResponse
    }

    func askLocationPermission() {
        askLocationPermissionCalls += 1
    }

    func askLastKnownLocation() {
        askLastKnownLocationCalls += 1
    }
}
