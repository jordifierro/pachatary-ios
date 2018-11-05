import XCTest
import RxSwift
@testable import Pachatary

class MyExperiencesPresenterTests: XCTestCase {

    func test_when_not_completely_registered_shows_register_view() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(false)
            .when_create()
            .then_should_call_show_register_view()
    }

    func test_on_experiences_response_success_shows_experiences() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_an_experience_repo_that_returns_for_mine(Result(.success, data: [Mock.experience("2"), Mock.experience("3")]))
            .given_a_profile_repo_that_returns_on_self(Result(.inProgress))
            .when_create()
            .then_should_call_show_profile_and_experiences_view()
            .then_should_call_getfirsts_mine_experiences()
            .then_should_show_experiences([Mock.experience("2"), Mock.experience("3")])
            .then_should_show_loading_experiences(false)
    }

    func test_on_experiences_response_inprogress() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_an_experience_repo_that_returns_for_mine(Result(.inProgress, data: []))
            .given_a_profile_repo_that_returns_on_self(Result(.inProgress))
            .when_create()
            .then_should_call_show_profile_and_experiences_view()
            .then_should_call_getfirsts_mine_experiences()
            .then_should_show_experiences([])
            .then_should_show_loading_experiences(true)
    }

    func test_on_experiences_response_error() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_an_experience_repo_that_returns_for_mine(Result(.error, error: DataError.noInternetConnection))
            .given_a_profile_repo_that_returns_on_self(Result(.inProgress))
            .when_create()
            .then_should_call_getfirsts_mine_experiences()
            .then_should_show_retry()
            .then_should_show_loading_experiences(false)
    }

    func test_on_profile_response_success() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_an_experience_repo_that_returns_for_mine(Result(.inProgress, data: []))
            .given_a_profile_repo_that_returns_on_self(Result(.success, data: Mock.profile("test")))
            .when_create()
            .then_should_call_show_profile_and_experiences_view()
            .then_should_call_getfirsts_mine_experiences()
            .then_should_show_profile(Mock.profile("test"))
            .then_should_show_loading_profile(false)
    }

    func test_on_profile_response_inprogress() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_an_experience_repo_that_returns_for_mine(Result(.inProgress, data: []))
            .given_a_profile_repo_that_returns_on_self(Result(.inProgress))
            .when_create()
            .then_should_call_show_profile_and_experiences_view()
            .then_should_call_getfirsts_mine_experiences()
            .then_should_show_loading_profile(true)
    }

    func test_on_profile_response_error() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_an_experience_repo_that_returns_for_mine(Result(.inProgress, data: []))
            .given_a_profile_repo_that_returns_on_self(Result(.error, error: DataError.notCached))
            .when_create()
            .then_should_call_show_profile_and_experiences_view()
            .then_should_call_getfirsts_mine_experiences()
            .then_should_show_retry()
            .then_should_show_loading_profile(false)
    }

    func test_on_retry_get_firsts_experiences() {
        ScenarioMaker()
            .when_retry()
            .then_should_call_getfirsts_mine_experiences()
    }

    func test_on_refresh_get_firsts_experiences() {
        ScenarioMaker()
            .when_refresh()
            .then_should_call_getfirsts_mine_experiences()
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

    func test_on_share_click_does_nothing_if_not_profile_nor_experiences_received() {
        ScenarioMaker()
            .when_share_click()
            .then_view_should_not_show_share_dialog()
            .then_view_should_not_show_not_enough_info_to_share()
    }

    func test_on_share_click_shows_not_enough_info_if_profile_has_no_picture() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_a_profile_repo_that_returns_on_self(Result(.success, data: Mock.profile("test")))
            .given_an_experience_repo_that_returns_for_mine(Result(.success, data: [Mock.experience("a")]))
            .when_create()
            .when_share_click()
            .then_view_should_show_not_enough_info_to_share()
            .then_view_should_not_show_share_dialog()
    }

    func test_on_share_click_shows_not_enough_info_if_experiences_is_empty() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_a_profile_repo_that_returns_on_self(Result(.success, data:
            Profile(username: "a", bio: "b", picture: LittlePicture(tinyUrl: "t", smallUrl: "s", mediumUrl: "m"), isMe: true)))
            .given_an_experience_repo_that_returns_for_mine(Result(.success, data: []))
            .when_create()
            .when_share_click()
            .then_view_should_show_not_enough_info_to_share()
            .then_view_should_not_show_share_dialog()
    }


    func test_on_share_click_shows_share_dialog_if_experiences_and_profile_picture() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns_to_is_register_completed(true)
            .given_a_profile_repo_that_returns_on_self(Result(.success, data:
                Profile(username: "test", bio: "b", picture: LittlePicture(tinyUrl: "t", smallUrl: "s", mediumUrl: "m"), isMe: true)))
            .given_an_experience_repo_that_returns_for_mine(Result(.success, data: [Mock.experience("a")]))
            .when_create()
            .when_share_click()
            .then_view_should_show_share_dialog(with: "test")
    }

    func test_on_edit_picture_click_navigates_to_pick_and_crop_image() {
        ScenarioMaker()
            .when_edit_profile_picture_click()
            .then_should_navigate_to_pick_and_crop_image()
    }

    func test_upload_profile_picture_inprogress() {
        ScenarioMaker()
            .given_a_profile_repo_that_returns_on_upload_picture(Result(.inProgress))
            .when_image_cropped()
            .then_should_show_upload_inprogress()
    }

    func test_upload_profile_picture_success() {
        ScenarioMaker()
            .given_a_profile_repo_that_returns_on_upload_picture(
                Result(.success, data: Mock.profile("a")))
            .when_image_cropped()
            .then_should_show_upload_success()
    }

    func test_upload_profile_picture_error() {
        ScenarioMaker()
            .given_a_profile_repo_that_returns_on_upload_picture(
                Result(.error, error: DataError.noInternetConnection))
            .when_image_cropped()
            .then_should_show_upload_error()
    }

    func test_on_bio_edited_calls_edit_profile() {
        ScenarioMaker()
            .given_a_profile_repo_that_returns_a_listener_observable_on_edit_profile()
            .when_bio_edited("new bio")
            .then_should_call_edit_profile_with("new bio")
            .then_should_subscribe_to_listener_observable()
    }

    class ScenarioMaker {
        let mockExperienceRepo = ExperienceRepoMock()
        let mockProfileRepo = ProfileRepositoryMock()
        let mockAuthRepo = AuthRepoMock()
        let mockView = MyExperiencesViewMock()
        let presenter: MyExperiencesPresenter!
        var listenerObservable = PublishSubject<Result<Profile>>()

        init() {
            presenter = MyExperiencesPresenter(mockExperienceRepo, mockProfileRepo, mockAuthRepo,
                                               CurrentThreadScheduler.instance, mockView)
        }

        func given_a_profile_repo_that_returns_a_listener_observable_on_edit_profile() -> ScenarioMaker {
            mockProfileRepo.editProfileResult = listenerObservable.asObservable()
            return self
        }

        func given_an_auth_repo_that_returns_to_is_register_completed(_ isCompleted: Bool) -> ScenarioMaker {
            mockAuthRepo.isRegisterCompletedResult = isCompleted
            return self
        }

        func given_an_experience_repo_that_returns_for_mine(
            _ result: Result<[Experience]>) -> ScenarioMaker {
            mockExperienceRepo.returnMineObservable = Observable.just(result)
            return self
        }

        func given_a_profile_repo_that_returns_on_self(_ result: Result<Profile>) -> ScenarioMaker {
            mockProfileRepo.selfProfileResult = Observable.just(result)
            return self
        }

        func given_a_profile_repo_that_returns_on_upload_picture(_ result: Result<Profile>) -> ScenarioMaker {
            mockProfileRepo.uploadProfilePictureResult = Observable.just(result)
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

        func when_share_click() -> ScenarioMaker {
            presenter.shareClick()
            return self
        }

        func when_edit_profile_picture_click() -> ScenarioMaker {
            presenter.editProfilePictureClick()
            return self
        }

        func when_image_cropped() -> ScenarioMaker {
            presenter.imageCropped(UIImage())
            return self
        }

        func when_bio_edited(_ bio: String) -> ScenarioMaker {
            presenter.bioEdited(bio)
            return self
        }

        func then_should_call_show_profile_and_experiences_view() -> ScenarioMaker {
            assert(mockView.showProfileAndExperiencesViewCalls == 1)
            return self
        }

        @discardableResult
        func then_should_call_getfirsts_mine_experiences() -> ScenarioMaker {
            assert(mockExperienceRepo.getFirstsCalls.count == 1)
            assert(mockExperienceRepo.getFirstsCalls[0].0 == .mine)
            assert(mockExperienceRepo.getFirstsCalls[0].1 == nil)
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
            assert([Kind.mine] == mockExperienceRepo.paginateCalls)
            return self
        }

        @discardableResult
        func then_view_should_show_share_dialog(with username: String) -> ScenarioMaker {
            assert(mockView.shareDialogCalls == [username])
            return self
        }

        @discardableResult
        func then_should_call_show_register_view() -> ScenarioMaker {
            assert(mockView.showRegisterViewCalls == 1)
            return self
        }

        @discardableResult
        func then_should_navigate_to_pick_and_crop_image() -> ScenarioMaker {
            assert(mockView.navigateToPickAndCropImageCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_upload_inprogress() -> ScenarioMaker {
            assert(mockView.showUploadInProgressCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_upload_success() -> ScenarioMaker {
            assert(mockView.showUploadSuccessCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_upload_error() -> ScenarioMaker {
            assert(mockView.showUploadErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_view_should_not_show_share_dialog() -> ScenarioMaker {
            assert(mockView.shareDialogCalls.isEmpty)
            return self
        }

        @discardableResult
        func then_view_should_not_show_not_enough_info_to_share() -> ScenarioMaker {
            assert(mockView.showNotEnoughInfoToShareCalls == 0)
            return self
        }

        @discardableResult
        func then_view_should_show_not_enough_info_to_share() -> ScenarioMaker {
            assert(mockView.showNotEnoughInfoToShareCalls == 1)
            return self
        }

        @discardableResult
        func then_should_call_edit_profile_with(_ bio: String) -> ScenarioMaker {
            assert(mockProfileRepo.editProfileCalls == [bio])
            return self
        }

        @discardableResult
        func then_should_subscribe_to_listener_observable() -> ScenarioMaker {
            assert(listenerObservable.hasObservers)
            return self
        }
    }
}

class MyExperiencesViewMock: MyExperiencesView {

    var showExperienceCalls: [[Experience]] = []
    var showProfileCalls: [Profile] = []
    var showLoadingExperiencesCalls: [Bool] = []
    var showLoadingProfileCalls: [Bool] = []
    var showRetryCalls = 0
    var navigateCalls: [String] = []
    var navigateToRegisterCalls = 0
    var shareDialogCalls: [String] = []
    var showProfileAndExperiencesViewCalls = 0
    var showRegisterViewCalls = 0
    var navigateToPickAndCropImageCalls = 0
    var showUploadInProgressCalls = 0
    var showUploadSuccessCalls = 0
    var showUploadErrorCalls = 0
    var showNotEnoughInfoToShareCalls = 0

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

    func navigateToRegister() {
        navigateToRegisterCalls += 1
    }

    func showShareDialog(_ username: String) {
        self.shareDialogCalls.append(username)
    }

    func showProfileAndExperiencesView() {
        showProfileAndExperiencesViewCalls += 1
    }

    func showRegisterView() {
        showRegisterViewCalls += 1
    }

    func navigateToPickAndCropImage() {
        navigateToPickAndCropImageCalls += 1
    }

    func showUploadInProgress() {
        showUploadInProgressCalls += 1
    }

    func showUploadSuccess() {
        showUploadSuccessCalls += 1
    }

    func showUploadError() {
        showUploadErrorCalls += 1
    }

    func showNotEnoughInfoToShare() {
        showNotEnoughInfoToShareCalls += 1
    }
}
