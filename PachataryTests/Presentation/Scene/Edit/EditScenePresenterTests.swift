import XCTest
import RxSwift
@testable import Pachatary

class EditScenePresenterTests: XCTestCase {

    enum Action {
        case create
        case retry
    }

    func test_create_response_inprogress() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("4", "9")
                .given_a_repo_that_returns_on_scene(Result(.inProgress))
                .when_do(action)
                .then_should_call_repo_scene("4", "9")
                .then_should_disable_button()
                .then_should_show_loader()
        }
    }

    func test_create_response_error() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("4", "9")
                .given_a_repo_that_returns_on_scene(
                    Result(.error, error: DataError.noInternetConnection))
                .when_do(action)
                .then_should_call_repo_scene("4", "9")
                .then_should_disable_button()
                .then_should_hide_loader()
                .then_should_show_retry()
        }
    }

    func test_create_response_success() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("4", "9")
                .given_a_repo_that_returns_on_scene(Result(.success, data: Mock.scene("4")))
                .when_do(action)
                .then_should_call_repo_scene("4", "9")
                .then_should_enable_button()
                .then_should_hide_loader()
                .then_should_fill_scene_data(Mock.scene("4"))
        }
    }

    func test_update_with_no_location_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .when_update_button_click()
            .then_should_show_no_location_error()
    }

    func test_update_with_no_title_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .given_a_latitude_and_longitude(2, -3.5)
            .when_update_button_click()
            .then_should_show_title_length_error()
    }

    func test_update_with_long_title_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .given_a_latitude_and_longitude(2, -3.5)
            .given_a_title(String(repeating: "5", count: 81))
            .when_update_button_click()
            .then_should_show_title_length_error()
    }

    func test_update_with_no_description_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .given_a_latitude_and_longitude(2, -3.5)
            .given_a_title("t")
            .when_update_button_click()
            .then_should_show_no_description_error()
    }

    func test_update_scene_response_inprogress() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .given_a_latitude_and_longitude(2, -3.5)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.inProgress))
            .when_update_button_click()
            .then_should_disable_button()
            .then_should_show_loader()
    }

    func test_update_scene_response_error() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .given_a_latitude_and_longitude(2, -3.5)
            .given_an_picture(UIImage())
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.error, error: DataError.noInternetConnection))
            .when_update_button_click()
           .then_should_enable_button()
            .then_should_hide_loader()
            .then_should_show_error()
    }

    func test_update_scene_response_success_without_new_picture() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .given_a_latitude_and_longitude(2, -3.5)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.success, data: Mock.scene("85")))
            .when_update_button_click()
            .then_should_call_repo_edit("9", "t", "d", 2, -3.5)
            .then_should_show_success()
            .then_should_finish()
    }

    func test_update_scene_response_success_with_new_picture() {
        let pic = UIImage()
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .given_a_latitude_and_longitude(2, -3.5)
            .given_an_picture(pic)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.success, data: Mock.scene("85")))
            .when_update_button_click()
            .then_should_call_repo_edit("9", "t", "d", 2, -3.5)
            .then_should_show_success_and_uploading_picture()
            .then_should_finish()
            .then_should_call_repo_upload_picture_with("9", pic)
    }

    func test_on_add_picture_button_click_navigates_to_pick_and_crop() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .when_add_picture_click()
            .then_should_navigate_to_pick_and_crop_image()
    }

    func test_on_select_location_click_navigates_to_select_location() {
        ScenarioMaker()
            .given_a_presenter("4", "9")
            .when_select_location_click()
            .then_should_navigate_to_select_location()
    }

    class ScenarioMaker {
        let mockView = EditSceneViewMock()
        let mockRepo = SceneRepoMock()
        var presenter: EditScenePresenter!

        func given_a_presenter(_ experienceId: String, _ sceneId: String) -> ScenarioMaker {
            presenter = EditScenePresenter(mockRepo, MainScheduler.instance,
                                           mockView, experienceId, sceneId)
            return self
        }

        func given_an_picture(_ image: UIImage) -> ScenarioMaker {
            mockView.pictureResult = image
            return self
        }

        func given_a_latitude_and_longitude(_ lat: Double, _ lon: Double) -> ScenarioMaker {
            mockView.latitudeResult = lat
            mockView.longitudeResult = lon
            return self
        }

        func given_a_title(_ title: String) -> ScenarioMaker {
            mockView.titleResult = title
            return self
        }

        func given_a_description(_ description: String) -> ScenarioMaker {
            mockView.descriptionResult = description
            return self
        }

        func given_a_repo_that_returns(_ result: Result<Scene>) -> ScenarioMaker {
            mockRepo.editSceneResult = Observable.just(result)
            return self
        }

        func given_a_repo_that_returns_on_scene(_ result: Result<Scene>) -> ScenarioMaker {
            mockRepo.sceneObservableResult = Observable.just(result)
            return self
        }

        func when_update_button_click() -> ScenarioMaker {
            presenter.updateButtonClick()
            return self
        }

        func when_do(_ action: Action) -> ScenarioMaker {
            switch action {
            case .create: presenter.create()
            case .retry: presenter.retry()
            }
            return self
        }

        func when_add_picture_click() -> ScenarioMaker {
            presenter.addPictureButtonClick()
            return self
        }

        func when_select_location_click() -> ScenarioMaker {
            presenter.selectLocationButtonClick()
            return self
        }

        @discardableResult
        func then_should_show_no_image_error() -> ScenarioMaker {
            assert(mockView.showNoPictureErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_title_length_error() -> ScenarioMaker {
            assert(mockView.showTitleLengthErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_no_description_error() -> ScenarioMaker {
            assert(mockView.showNoDescriptionErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_no_location_error() -> ScenarioMaker {
            assert(mockView.showNoLocationErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_should_disable_button() -> ScenarioMaker {
            assert(mockView.disableButtonCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_retry() -> ScenarioMaker {
            assert(mockView.showRetryCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_loader() -> ScenarioMaker {
            assert(mockView.showLoaderCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_error() -> ScenarioMaker {
            assert(mockView.showErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_success() -> ScenarioMaker {
            assert(mockView.showSuccessCalls == 1)
            return self
        }

        @discardableResult
        func then_should_hide_loader() -> ScenarioMaker {
            assert(mockView.hideLoaderCalls == 1)
            return self
        }

        @discardableResult
        func then_should_enable_button() -> ScenarioMaker {
            assert(mockView.enableButtonCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_success_and_uploading_picture() -> ScenarioMaker {
            assert(mockView.showSuccessAndUploadingPictureCalls == 1)
            return self
        }

        @discardableResult
        func then_should_finish() -> ScenarioMaker {
            assert(mockView.finishCalls == 1)
            return self
        }

        @discardableResult
        func then_should_call_repo_upload_picture_with(_ sceneId: String,
                                                       _ image: UIImage) -> ScenarioMaker {
            assert(mockRepo.uploadPictureCalls.count == 1)
            assert(mockRepo.uploadPictureCalls[0].0 == sceneId)
            assert(mockRepo.uploadPictureCalls[0].1 == image)
            return self
        }

        @discardableResult
        func then_should_call_repo_edit(_ sceneId: String, _ title: String,
                                        _ description: String, _ latitude: Double,
                                        _ longitude: Double) -> ScenarioMaker {
            assert(mockRepo.editSceneCalls.count == 1)
            assert(mockRepo.editSceneCalls[0].0 == sceneId)
            assert(mockRepo.editSceneCalls[0].1 == title)
            assert(mockRepo.editSceneCalls[0].2 == description)
            assert(mockRepo.editSceneCalls[0].3 == latitude)
            assert(mockRepo.editSceneCalls[0].4 == longitude)
            return self
        }

        @discardableResult
        func then_should_call_repo_scene(_ experienceId: String,
                                         _ sceneId: String) -> ScenarioMaker {
            assert(mockRepo.sceneObservableCalls.count == 1)
            assert(mockRepo.sceneObservableCalls[0].0 == experienceId)
            assert(mockRepo.sceneObservableCalls[0].1 == sceneId)
            return self
        }

        @discardableResult
        func then_should_fill_scene_data(_ scene: Scene) -> ScenarioMaker {
            assert(mockView.fillSceneDataCalls == [scene])
            return self
        }

        @discardableResult
        func then_should_navigate_to_pick_and_crop_image() -> ScenarioMaker {
            assert(mockView.navigateToPickAndCropImageCalls == 1)
            return self
        }

        @discardableResult
        func then_should_navigate_to_select_location() -> ScenarioMaker {
            assert(mockView.navigateToSelectLocationCalls == 1)
            return self
        }
    }
}

class EditSceneViewMock: EditSceneView {

    var titleResult = ""
    var descriptionResult = ""
    var pictureResult: UIImage?
    var showLoaderCalls = 0
    var hideLoaderCalls = 0
    var enableButtonCalls = 0
    var disableButtonCalls = 0
    var showErrorCalls = 0
    var showSuccessAndUploadingPictureCalls = 0
    var showSuccessCalls = 0
    var showTitleLengthErrorCalls = 0
    var showNoDescriptionErrorCalls = 0
    var showNoPictureErrorCalls = 0
    var navigateToPickAndCropImageCalls = 0
    var finishCalls = 0
    var showRetryCalls = 0
    var fillSceneDataCalls = [Scene]()
    var latitudeResult: Double?
    var longitudeResult: Double?
    var navigateToSelectLocationCalls = 0
    var showNoLocationErrorCalls = 0

    func title() -> String { return titleResult }
    func description() -> String { return descriptionResult }
    func picture() -> UIImage? { return pictureResult }
    func showLoader() { showLoaderCalls += 1 }
    func hideLoader() { hideLoaderCalls += 1 }
    func enableUpdateButton() { enableButtonCalls += 1 }
    func disableUpdateButton() { disableButtonCalls += 1 }
    func showError() { showErrorCalls += 1 }
    func showSuccessAndUploadingPicture() { showSuccessAndUploadingPictureCalls += 1 }
    func showSuccess() { showSuccessCalls += 1 }
    func showTitleLengthError() { showTitleLengthErrorCalls += 1 }
    func showNoDescriptionError() { showNoDescriptionErrorCalls += 1 }
    func showNoPictureError() { showNoPictureErrorCalls += 1 }
    func navigateToPickAndCropImage() { navigateToPickAndCropImageCalls += 1 }
    func finish() { finishCalls += 1 }
    func showRetry() { showRetryCalls += 1 }
    func fillSceneData(_ scene: Scene) { fillSceneDataCalls.append(scene) }
    func latitude() -> Double? { return latitudeResult }
    func longitude() -> Double? { return longitudeResult }
    func showNoLocationError() { showNoLocationErrorCalls += 1 }
    func navigateToSelectLocation() { navigateToSelectLocationCalls += 1 }
}
