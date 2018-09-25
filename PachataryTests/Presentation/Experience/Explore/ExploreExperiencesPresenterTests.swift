import XCTest
import RxSwift
@testable import Pachatary

class ExploreExperiencesPresenterTests: XCTestCase {
    
    func test_on_create_asks_experiences_response_success() {
        ScenarioMaker()
            .given_an_experience(id: "7")
            .given_an_experience(id: "8")
            .given_an_experience_repo_that_returns_that_experiences()
            .when_create()
            .then_should_call_get_firsts_kind_explore()
            .then_should_show_experiences()
            .then_should_show_loader(false)
            .then_should_show_pagination_loader(false)
            .then_should_show_retry(false)
            .then_should_show_error(false)
    }

    func test_on_create_asks_experiences_response_inprogress_getfirsts() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_in_progress(.getFirsts)
            .when_create()
            .then_should_call_get_firsts_kind_explore()
            .then_should_show_loader(true)
            .then_should_show_pagination_loader(false)
            .then_should_show_retry(false)
            .then_should_show_error(false)
    }

    func test_on_create_asks_experiences_response_inprogress_paginate() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_in_progress(.paginate)
            .when_create()
            .then_should_call_get_firsts_kind_explore()
            .then_should_show_loader(false)
            .then_should_show_pagination_loader(true)
            .then_should_show_retry(false)
            .then_should_show_error(false)
    }

    func test_on_create_asks_experiences_response_error() {
        ScenarioMaker()
            .given_an_experience_repo_that_returns_error()
            .when_create()
            .then_should_call_get_firsts_kind_explore()
            .then_should_show_loader(false)
            .then_should_show_pagination_loader(false)
            .then_should_show_retry(true)
            .then_should_show_error(true)
    }
    
    func test_on_retry_get_firsts_experiences() {
        ScenarioMaker()
            .when_retry()
            .then_should_call_get_firsts_kind_explore()
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
        var mockView: ExploreExperiencesViewMock!
        var presenter: ExploreExperiencesPresenter!

        init() {
            mockView = ExploreExperiencesViewMock()
            presenter = ExploreExperiencesPresenter(mockExperienceRepo,
                                                    CurrentThreadScheduler.instance)
            presenter.view = mockView
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
        func then_should_call_get_firsts_kind_explore() -> ScenarioMaker {
            assert([Kind.explore] == mockExperienceRepo.getFirstsCalls)
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
    }
}

class ExploreExperiencesViewMock: ExploreExperiencesView {

    var showCalls: [[Experience]] = []
    var showLoaderCalls: [Bool] = []
    var showPaginationLoaderCalls: [Bool] = []
    var showErrorCalls: [Bool] = []
    var showRetryCalls: [Bool] = []
    var navigateCalls: [String] = []

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
}
