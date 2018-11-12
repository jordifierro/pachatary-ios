import XCTest
import RxSwift

@testable import Pachatary

class ExperienceScenesPresenterTests: XCTestCase {

    enum Action {
        case create
        case retry
    }
    
    func test_editable_experience_response_success() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("7", isExperienceEditableIfMine: true)
                .given_an_scenes_observable_result(Result(.inProgress), experienceId: "7")
                .given_an_experience_observable_result(Result(.success, data: Mock.experience("9")))
                .when(do: action)
                .then_should_call_experience_repo_observable_with(experienceId: "7")
                .then_should_call_show_experience(Mock.experience("9"), true)
                .then_should_call_show_experience_loader(false)
        }
    }

    func test_experience_response_success() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("7", isExperienceEditableIfMine: false)
                .given_an_scenes_observable_result(Result(.inProgress), experienceId: "7")
                .given_an_experience_observable_result(Result(.success, data: Mock.experience("9")))
                .when(do: action)
                .then_should_call_experience_repo_observable_with(experienceId: "7")
                .then_should_call_show_experience(Mock.experience("9"), false)
                .then_should_call_show_experience_loader(false)
        }
    }

    func test_experience_response_inprogress() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("7")
                .given_an_scenes_observable_result(Result(.inProgress), experienceId: "7")
                .given_an_experience_observable_result(Result(.inProgress))
                .when(do: action)
                .then_should_call_experience_repo_observable_with(experienceId: "7")
                .then_should_call_show_experience_loader(true)
        }
    }

    func test_experience_response_error() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("7")
                .given_an_scenes_observable_result(Result(.inProgress), experienceId: "7")
                .given_an_experience_observable_result(Result(.error, error: DataError.noInternetConnection))
                .when(do: action)
                .then_should_call_experience_repo_observable_with(experienceId: "7")
                .then_should_show_retry()
                .then_should_call_show_experience_loader(false)
        }
    }

    func test_scenes_response_success() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("7")
                .given_an_scenes_observable_result(Result(.success, data:
                    [Mock.scene("1"), Mock.scene("2")]), experienceId: "7")
                .given_an_experience_observable_result(Result(.inProgress))
                .when(do: action)
                .then_should_call_scene_repo_observable_with(experienceId: "7")
                .then_should_call_show_scenes([Mock.scene("1"), Mock.scene("2")])
                .then_should_show_scenes_loader(false)
        }
    }

    func test_scenes_response_inprogress() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("7")
                .given_an_scenes_observable_result(Result(.inProgress), experienceId: "7")
                .given_an_experience_observable_result(Result(.inProgress))
                .when(do: action)
                .then_should_call_scene_repo_observable_with(experienceId: "7")
                .then_should_show_scenes_loader(true)
        }
    }

    func test_scenes_response_error() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("7")
                .given_an_scenes_observable_result(
                    Result(.error, error: DataError.noInternetConnection), experienceId: "7")
                .given_an_experience_observable_result(Result(.inProgress))
                .when(do: action)
                .then_should_call_scene_repo_observable_with(experienceId: "7")
                .then_should_show_retry()
                .then_should_show_scenes_loader(false)
        }
    }

    func test_on_go_to_map_click_navigates_to_map() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_go_to_map_click()
            .then_should_navigate_to_map()
    }
    
    func test_on_locate_scene_click_navigates_to_map_with_scene_id() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_locate_scene_click("7")
            .then_should_navigate_to_map(sceneId: "7")
    }
    
    func test_on_resume_scroll_to_scene_id_if_selected_scene_id() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_selected_scene_id("5")
            .when_resume_presenter()
            .should_scroll_to_scene_id("5")
    }
    
    func test_on_resume_scroll_to_scene_id_if_selected_scene_id_only_once() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_selected_scene_id("5")
            .when_resume_presenter()
            .when_resume_presenter()
            .when_resume_presenter()
            .should_scroll_to_scene_id("5")
    }
    
    func test_on_resume_doesnt_scroll_if_not_selected_scene_id() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_selected_scene_id(nil)
            .when_resume_presenter()
            .should_not_scroll_to_scene_id()
    }
    
    func test_save() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_save_click(true)
            .then_should_call_repo_save("4", true)
    }
    
    func test_unsave_click_opens_confirmation_dialog() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_save_click(false)
            .then_should_show_unsave_confirmation_dialog()
    }

    func test_unsave_confirmation_ok_unsaves_experience() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_unsave_dialog_ok()
            .then_should_call_repo_save("4", false)
    }

    func test_share() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_experience_share_url_observable_result(Result(.success, data: "exp-url"))
            .when_share_click()
            .then_should_call_repo_share_url("4")
            .then_should_show_share_dialog(with: "exp-url")
    }

    func test_share_inprogress() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_experience_share_url_observable_result(Result(.inProgress))
            .when_share_click()
            .then_should_call_repo_share_url("4")
            .then_should_not_show_share_dialog()
    }

    func test_share_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_experience_share_url_observable_result(Result(.error, error: DataError.noInternetConnection))
            .when_share_click()
            .then_should_call_repo_share_url("4")
            .then_should_not_show_share_dialog()
    }

    func test_profile_click_when_can_navigate_to_profile() {
        ScenarioMaker()
            .given_a_presenter("4", canNavigateToProfile: true)
            .when_profile_click("user")
            .then_should_navigate_to_profile("user")
    }

    func test_profile_click_when_can_not_navigate_to_profile() {
        ScenarioMaker()
            .given_a_presenter("4", canNavigateToProfile: false)
            .when_profile_click("user")
            .then_should_finish()
    }

    func test_refresh_calls_repo_refreshes() {
        ScenarioMaker()
            .given_a_presenter("5")
            .when_refresh()
            .then_should_call_experience_repo_refresh("5")
            .then_should_call_scene_repo_refresh("5")
    }

    func test_edit_click() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_edit_click()
            .then_should_navigate_to_edit_experience()
    }

    func test_add_click() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_add_click()
            .then_should_navigate_to_add_scene()
    }

    func test_edit_scene_click() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_edit_scene_click("7")
            .then_should_navigate_to_edit_scene("7")
    }

    func test_flag_click() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_flag_click()
            .then_should_show_flag_options_dialog()
    }

    func test_flag_call_result_success() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_experience_repo_that_returns_on_flag(Result(.success, data: true))
            .when_flag_reason_chosen("Inappropiate")
            .then_should_call_repo_flag("4", "Inappropiate")
            .then_should_show_flag_success()
    }

    func test_flag_call_result_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_experience_repo_that_returns_on_flag(
                Result(.error, error: DataError.noInternetConnection))
            .when_flag_reason_chosen("Inappropiate")
            .then_should_call_repo_flag("4", "Inappropiate")
            .then_should_show_flag_error()
    }

    class ScenarioMaker {
        let mockSceneRepo = SceneRepoMock()
        let mockExperienceRepo = ExperienceRepoMock()
        var mockView = ExperienceScenesViewMock()
        var presenter: ExperienceScenesPresenter!
        
        init() {}
        
        func given_a_presenter(_ experienceId: String,
                               canNavigateToProfile: Bool = true,
                               isExperienceEditableIfMine: Bool = false) -> ScenarioMaker {
            presenter = ExperienceScenesPresenter(mockSceneRepo, mockExperienceRepo,
                                                  CurrentThreadScheduler.instance,
                                                  mockView, experienceId, canNavigateToProfile,
                                                  isExperienceEditableIfMine)
            return self
        }
        
        func given_a_selected_scene_id(_ sceneId: String?) -> ScenarioMaker {
            presenter.selectedSceneId = sceneId
            return self
        }
        
        func given_an_scenes_observable_result(_ result: Result<[Scene]>, experienceId: String) -> ScenarioMaker {
            mockSceneRepo.resultSceneForExperience[experienceId] = result
            return self
        }

        func given_an_experience_repo_that_returns_on_flag(_ result: Result<Bool>) -> ScenarioMaker {
            mockExperienceRepo.flagExperienceResult = Observable.just(result)
            return self
        }
        
        func given_an_experience_observable_result(_ result: Result<Experience>) -> ScenarioMaker {
            mockExperienceRepo.returnExperienceObservable = Observable.just(result)
            return self
        }

        func given_an_experience_share_url_observable_result(_ result: Result<String>) -> ScenarioMaker {
            mockExperienceRepo.returnShareUrlObservable = Observable.just(result)
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
        
        func when_resume_presenter() -> ScenarioMaker {
            presenter.resume()
            return self
        }
        
        func when_save_click(_ save: Bool) -> ScenarioMaker {
            presenter.saveExperience(save: save)
            return self
        }
        
        func when_go_to_map_click() -> ScenarioMaker {
            presenter.onGoToMapClick()
            return self
        }
        
        func when_locate_scene_click(_ sceneId: String) -> ScenarioMaker {
            presenter.onLocateSceneClick(sceneId)
            return self
        }

        func when_unsave_dialog_ok() -> ScenarioMaker {
            presenter.onUnsaveDialogOk()
            return self
        }

        func when_share_click() -> ScenarioMaker {
            presenter.shareClick()
            return self
        }

        func when_profile_click(_ username: String) -> ScenarioMaker {
            presenter.profileClick(username)
            return self
        }

        func when_edit_scene_click(_ sceneId: String) -> ScenarioMaker {
            presenter.editSceneClick(sceneId)
            return self
        }

        func when_refresh() -> ScenarioMaker {
            presenter.refresh()
            return self
        }

        func when_edit_click() -> ScenarioMaker {
            presenter.editClick()
            return self
        }

        func when_add_click() -> ScenarioMaker {
            presenter.addClick()
            return self
        }

        func when_flag_click() -> ScenarioMaker {
            presenter.flagClick()
            return self
        }

        func when_flag_reason_chosen(_ reason: String) -> ScenarioMaker {
            presenter.flagReasonChosen(reason)
            return self
        }
        
        @discardableResult
        func then_should_call_scene_repo_observable_with(experienceId: String) -> ScenarioMaker {
            assert(mockSceneRepo.scenesObservableCalls == [experienceId])
            return self
        }
        
        @discardableResult
        func then_should_call_experience_repo_observable_with(experienceId: String) -> ScenarioMaker {
            assert(mockExperienceRepo.singleExperienceCalls == [experienceId])
            return self
        }
        
        @discardableResult
        func then_should_call_show_scenes(_ scenes: [Scene]) -> ScenarioMaker {
            assert(scenes == mockView.showScenesCalls[0])
            return self
        }

        @discardableResult
        func then_should_show_scenes_loader(_ isLoading: Bool) -> ScenarioMaker {
            assert(mockView.showLoadingScenesCalls == [isLoading])
            return self
        }

        @discardableResult
        func then_should_call_show_experience(_ experience: Experience,
                                              _ isExperienceEditableIfMine: Bool) -> ScenarioMaker {
            assert(mockView.showExperienceCalls.count == 1)
            assert(mockView.showExperienceCalls[0].0 == experience)
            assert(mockView.showExperienceCalls[0].1 == isExperienceEditableIfMine)
            return self
        }

        @discardableResult
        func then_should_navigate_to_map(sceneId: String? = nil) -> ScenarioMaker {
            assert(mockView.navigateToMapCalls == [sceneId])
            return self
        }
        
        @discardableResult
        func should_scroll_to_scene_id(_ sceneId: String) -> ScenarioMaker {
            assert(mockView.scrollToSceneCalls == [sceneId])
            return self
        }
        
        @discardableResult
        func should_not_scroll_to_scene_id() -> ScenarioMaker {
            assert(mockView.scrollToSceneCalls == [])
            return self
        }
        
        @discardableResult
        func then_should_call_repo_save(_ experienceId: String, _ save: Bool) -> ScenarioMaker {
            assert(mockExperienceRepo.saveCalls.count == 1)
            assert(mockExperienceRepo.saveCalls[0].0 == experienceId)
            assert(mockExperienceRepo.saveCalls[0].1 == save)
            return self
        }

        @discardableResult
        func then_should_call_repo_flag(_ experienceId: String, _ reason: String) -> ScenarioMaker {
            assert(mockExperienceRepo.flagExperienceCalls.count == 1)
            assert(mockExperienceRepo.flagExperienceCalls[0].0 == experienceId)
            assert(mockExperienceRepo.flagExperienceCalls[0].1 == reason)
            return self
        }

        @discardableResult
        func then_should_call_repo_share_url(_ experienceId: String) -> ScenarioMaker {
            assert(mockExperienceRepo.shareUrlCalls.count == 1)
            assert(mockExperienceRepo.shareUrlCalls[0] == experienceId)
            return self

        }

        @discardableResult
        func then_should_show_unsave_confirmation_dialog() -> ScenarioMaker {
            assert(mockView.showUnsaveConfirmationDialogCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_share_dialog(with url: String) -> ScenarioMaker {
            assert(mockView.showShareDialogCalls == [url])
            return self
        }

        @discardableResult
        func then_should_not_show_share_dialog() -> ScenarioMaker {
            assert(mockView.showShareDialogCalls.count == 0)
            return self
        }

        @discardableResult
        func then_should_navigate_to_profile(_ username: String) -> ScenarioMaker {
            assert(mockView.navigateToProfileCalls == [username])
            return self
        }

        @discardableResult
        func then_should_call_show_experience_loader(_ isLoading: Bool) -> ScenarioMaker {
            assert(mockView.showLoadingExperienceCalls == [isLoading])
            return self
        }

        @discardableResult
        func then_should_show_retry() -> ScenarioMaker {
            assert(mockView.showRetryCalls == 1)
            return self
        }

        @discardableResult
        func then_should_call_experience_repo_refresh(_ experienceId: String) -> ScenarioMaker {
            assert(mockExperienceRepo.refreshExperienceCalls == [experienceId])
            return self
        }

        @discardableResult
        func then_should_call_scene_repo_refresh(_ experienceId: String) -> ScenarioMaker {
            assert(mockSceneRepo.refreshScenesCalls == [experienceId])
            return self
        }

        @discardableResult
        func then_should_navigate_to_edit_experience() -> ScenarioMaker {
            assert(mockView.navigateToEditExperienceCalls == 1)
            return self
        }

        @discardableResult
        func then_should_finish() -> ScenarioMaker {
            assert(mockView.finishCalls == 1)
            return self
        }

        @discardableResult
        func then_should_navigate_to_add_scene() -> ScenarioMaker {
            assert(mockView.navigateToAddSceneCalls == 1)
            return self
        }

        @discardableResult
        func then_should_navigate_to_edit_scene(_ sceneId: String) -> ScenarioMaker {
            assert(mockView.navigateToEditSceneCalls == [sceneId])
            return self
        }

        @discardableResult
        func then_should_show_flag_options_dialog() -> ScenarioMaker {
            assert(mockView.showFlagOptionsDialogCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_flag_success() -> ScenarioMaker {
            assert(mockView.showFlagSuccessCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_flag_error() -> ScenarioMaker {
            assert(mockView.showFlagErrorCalls == 1)
            return self
        }
    }
}

class ExperienceScenesViewMock: ExperienceScenesView {

    var showScenesCalls = [[Scene]]()
    var showExperienceCalls = [(Experience, Bool)]()
    var showLoadingExperienceCalls = [Bool]()
    var showLoadingScenesCalls = [Bool]()
    var showRetryCalls = 0
    var navigateToMapCalls = [String?]()
    var navigateToProfileCalls = [String]()
    var navigateToEditExperienceCalls = 0
    var finishCalls = 0
    var scrollToSceneCalls = [String]()
    var showUnsaveConfirmationDialogCalls = 0
    var showShareDialogCalls = [String]()
    var navigateToAddSceneCalls = 0
    var navigateToEditSceneCalls = [String]()
    var showFlagSuccessCalls = 0
    var showFlagErrorCalls = 0
    var showFlagOptionsDialogCalls = 0

    func showScenes(_ scenes: [Scene]) {
        showScenesCalls.append(scenes)
    }

    func showExperience(_ experience: Experience, _ isExperienceEditableIfMine: Bool) {
        showExperienceCalls.append((experience, isExperienceEditableIfMine))
    }

    func showExperienceLoading(_ isLoading: Bool) {
        showLoadingExperienceCalls.append(isLoading)
    }

    func showSceneLoading(_ isLoading: Bool) {
        showLoadingScenesCalls.append(isLoading)
    }

    func showRetry() {
        showRetryCalls += 1
    }

    func navigateToMap(_ sceneId: String?) {
        navigateToMapCalls.append(sceneId)
    }
    
    func scrollToScene(_ sceneId: String) {
        scrollToSceneCalls.append(sceneId)
    }

    func showUnsaveConfirmationDialog() {
        showUnsaveConfirmationDialogCalls += 1
    }

    func finish() {
        finishCalls += 1
    }

    func showShareDialog(_ url: String) {
        showShareDialogCalls.append(url)
    }

    func navigateToProfile(_ username: String) {
        navigateToProfileCalls.append(username)
    }

    func navigateToEditExperience() {
        navigateToEditExperienceCalls += 1
    }

    func navigateToAddScene() {
        navigateToAddSceneCalls += 1
    }

    func navigateToEditScene(_ sceneId: String) {
        navigateToEditSceneCalls.append(sceneId)
    }

    func showFlagSuccess() {
        showFlagSuccessCalls += 1
    }

    func showFlagError() {
        showFlagErrorCalls += 1
    }

    func showFlagOptionsDialog() {
        showFlagOptionsDialogCalls += 1
    }
}
