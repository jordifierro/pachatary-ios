import XCTest
import RxSwift
@testable import Pachatary

class ExploreExperiencesPresenterTests: XCTestCase {
    
    enum Action {
        case create
        case retry
        
        static let values = [create, retry]
    }
    
    func test_on_create_asks_experiences_if_has_credentials_response_success() {
        for action in Action.values {
            ScenarioMaker()
                .given_an_experience(id: "7")
                .given_an_experience(id: "8")
                .given_an_experience_repo_that_returns_that_experiences()
                .given_an_auth_repo_with_credentials(true)
                .when(action: action)
                .then_should_call_get_firsts_kind_explore()
                .then_should_show_experiences()
                .then_should_show_loader(false)
                .then_should_show_pagination_loader(false)
                .then_should_show_retry(false)
                .then_should_show_error(false)
        }
    }

    func test_on_create_asks_experiences_if_has_credentials_response_inprogress_getfirsts() {
        for action in Action.values {
            ScenarioMaker()
                .given_an_experience_repo_that_returns_in_progress(.getFirsts)
                .given_an_auth_repo_with_credentials(true)
                .when(action: action)
                .then_should_call_get_firsts_kind_explore()
                .then_should_show_loader(true)
                .then_should_show_pagination_loader(false)
                .then_should_show_retry(false)
                .then_should_show_error(false)
        }
    }

    func test_on_create_asks_experiences_if_has_credentials_response_inprogress_paginate() {
        for action in Action.values {
            ScenarioMaker()
                .given_an_experience_repo_that_returns_in_progress(.paginate)
                .given_an_auth_repo_with_credentials(true)
                .when(action: action)
                .then_should_call_get_firsts_kind_explore()
                .then_should_show_loader(false)
                .then_should_show_pagination_loader(true)
                .then_should_show_retry(false)
                .then_should_show_error(false)
        }
    }

    func test_on_create_asks_experiences_if_has_credentials_response_error() {
        for action in Action.values {
            ScenarioMaker()
                .given_an_experience_repo_that_returns_error()
                .given_an_auth_repo_with_credentials(true)
                .when(action: action)
                .then_should_call_get_firsts_kind_explore()
                .then_should_show_loader(false)
                .then_should_show_pagination_loader(false)
                .then_should_show_retry(true)
                .then_should_show_error(true)
        }
    }

    func test_on_create_no_credentials_response_inprogress() {
        for action in Action.values {
            ScenarioMaker()
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns_inprogress()
                .when(action: action)
                .then_should_not_call_get_firsts()
                .then_should_show_loader(true)
                .then_should_show_retry(false)
        }
    }

    func test_on_create_no_credentials_response_error() {
        for action in Action.values {
            ScenarioMaker()
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_repo_that_returns_error()
                .when(action: action)
                .then_should_not_call_get_firsts()
                .then_should_show_loader(false)
                .then_should_show_retry(true)
                .then_should_show_error(true)
        }
    }

    func test_on_create_get_person_invitation_and_asks_experiences_if_has_no_credentials() {
        for action in Action.values {
            ScenarioMaker()
                .given_an_experience(id: "7")
                .given_an_experience(id: "8")
                .given_an_experience_repo_that_returns_that_experiences()
                .given_an_auth_repo_with_credentials(false)
                .given_an_auth_token()
                .given_an_auth_repo_that_returns_that_auth_token_on_get_invitation()
                .when(action: action)
                .then_should_call_get_firsts_kind_explore()
                .then_should_show_experiences()
                .then_should_show_loader(false)
                .then_should_show_pagination_loader(false)
                .then_should_show_retry(false)
                .then_should_show_error(false)
        }
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
        let mockAuthRepo = AuthRepoMock()
        var mockView: ExploreExperiencesViewMock!
        var presenter: ExploreExperiencesPresenter!
        var authToken: AuthToken!

        init() {
            mockView = ExploreExperiencesViewMock()
            presenter = ExploreExperiencesPresenter(mockExperienceRepo,
                                                    mockAuthRepo, CurrentThreadScheduler.instance)
            presenter.view = mockView
        }

        func given_an_experience(id: String, title: String = "", description: String = "",
                                 picture: Picture? = nil, isMine: Bool = false,
                                 isSaved: Bool = false, authorUsername: String = "",
                                 savesCount: Int = 0) -> ScenarioMaker {
            experiences.append(Experience(id: id, title: title, description: description,
                                          picture: picture, isMine: isMine, isSaved: isSaved,
                                          authorUsername: authorUsername, savesCount: savesCount))
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
        
        func given_an_auth_repo_with_credentials(_ hasCredentials: Bool) -> ScenarioMaker {
            mockAuthRepo.hasPersonCredentialsResponse = hasCredentials
            return self
        }
        
        func given_an_auth_repo_that_returns_inprogress() -> ScenarioMaker {
            mockAuthRepo.returnInProgress = true
            return self
        }
        
        func given_an_auth_repo_that_returns_error() -> ScenarioMaker {
            mockAuthRepo.returnError = DataError.noInternetConnection
            return self
        }
        
        func given_an_auth_token() -> ScenarioMaker {
            authToken = AuthToken(accessToken: "a", refreshToken: "r")
            return self
        }

        func given_an_auth_repo_that_returns_that_auth_token_on_get_invitation() -> ScenarioMaker {
            mockAuthRepo.authToken = self.authToken
            return self
        }

        func when(action: Action) -> ScenarioMaker {
            switch action {
            case .create:
                presenter.create()
            case .retry:
                presenter.retryClick()
            }
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
    
    func navigateToExperienceMap(_ experienceId: String) {
        self.navigateCalls.append(experienceId)
    }
}

class AuthRepoMock: AuthRepository {

    var hasPersonCredentialsResponse: Bool!
    var authToken: AuthToken!
    var returnInProgress = false
    var returnError: DataError? = nil
    
    func hasPersonCredentials() -> Bool {
        return self.hasPersonCredentialsResponse
    }
    
    func getPersonInvitation() -> Observable<Result<AuthToken>> {
        var result: Result<AuthToken>?
        if returnInProgress { result = Result(.inProgress) }
        else if returnError != nil { result = Result(error: returnError!) }
        else { result =  Result(.success, data: authToken)}
        return Observable.just(result!)
    }
}
