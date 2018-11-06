import XCTest
import RxSwift
@testable import Pachatary

class CreateScenePresenterTests: XCTestCase {

    func test_no_image_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_create_button_click()
            .then_should_show_no_image_error()
    }

    func test_no_location_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(UIImage())
            .when_create_button_click()
            .then_should_show_no_location_error()
    }

    func test_no_title_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(UIImage())
            .given_a_latitude(2)
            .given_a_longitude(-0.4)
            .when_create_button_click()
            .then_should_show_title_length_error()
    }

    func test_long_title_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(UIImage())
            .given_a_latitude(2)
            .given_a_longitude(-0.4)
            .given_a_title(String(repeating: "5", count: 81))
            .when_create_button_click()
            .then_should_show_title_length_error()
    }

    func test_no_description_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(UIImage())
            .given_a_latitude(2)
            .given_a_longitude(-0.4)
            .given_a_title("t")
            .when_create_button_click()
            .then_should_show_no_description_error()
    }

    func test_create_scene_response_inprogress() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(UIImage())
            .given_a_latitude(2)
            .given_a_longitude(-0.4)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.inProgress))
            .when_create_button_click()
            .then_should_call_api_create_with("4", "t", "d", 2, -0.4)
            .then_should_disable_button()
            .then_should_show_loader()
    }

    func test_create_scene_response_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(UIImage())
            .given_a_latitude(2)
            .given_a_longitude(-0.4)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.error, error: DataError.noInternetConnection))
            .when_create_button_click()
            .then_should_call_api_create_with("4", "t", "d", 2, -0.4)
            .then_should_enable_button()
            .then_should_hide_loader()
            .then_should_show_error()
    }

    func test_create_scene_response_success() {
        let pic = UIImage()
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(pic)
            .given_a_latitude(2)
            .given_a_longitude(-0.4)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.success, data: Mock.scene("85")))
            .when_create_button_click()
            .then_should_call_api_create_with("4", "t", "d", 2, -0.4)
            .then_should_show_success_and_uploading_picture()
            .then_should_finish()
            .then_should_call_repo_upload_picture_with("85", pic)
    }

    func test_select_location_click_navigates_with_selected_location_first() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_found_latitude(3)
            .given_a_found_longitude(4)
            .given_a_latitude(1)
            .given_a_longitude(2)
            .when_select_location_click()
            .then_should_navigate_to_select_location(1, 2)
    }

    func test_select_location_click_navigates_with_last_known_if_no_selected() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_found_latitude(3)
            .given_a_found_longitude(4)
            .when_select_location_click()
            .then_should_navigate_to_select_location(3, 4)
    }

    func test_select_location_click_navigates_without_initial_if_no_location_found_nor_selected() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_select_location_click()
            .then_should_navigate_to_select_location(nil, nil)
    }

    func test_on_create_tries_to_find_last_known_location() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_create()
            .then_should_try_to_find_last_known_location()
    }

    class ScenarioMaker {
        let mockView = CreateSceneViewMock()
        let mockRepo = SceneRepoMock()
        var presenter: CreateScenePresenter!

        func given_a_presenter(_ experienceId: String) -> ScenarioMaker {
            presenter = CreateScenePresenter(mockRepo, MainScheduler.instance, mockView, experienceId)
            return self
        }

        func given_an_picture(_ image: UIImage) -> ScenarioMaker {
            mockView.pictureResult = image
            return self
        }

        func given_a_latitude(_ latitude: Double) -> ScenarioMaker {
            mockView.latitudeResult = latitude
            return self
        }

        func given_a_longitude(_ longitude: Double) -> ScenarioMaker {
            mockView.longitudeResult = longitude
            return self
        }

        func given_a_found_latitude(_ latitude: Double) -> ScenarioMaker {
            mockView.latitudeResult = latitude
            return self
        }

        func given_a_found_longitude(_ longitude: Double) -> ScenarioMaker {
            mockView.longitudeResult = longitude
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
            mockRepo.createSceneResult = Observable.just(result)
            return self
        }

        func when_create_button_click() -> ScenarioMaker {
            presenter.createButtonClick()
            return self
        }

        func when_create() -> ScenarioMaker {
            presenter.create()
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
        func then_should_disable_button() -> ScenarioMaker {
            assert(mockView.disableButtonCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_loader() -> ScenarioMaker {
            assert(mockView.showLoaderCalls == 1)
            return self
        }

        @discardableResult
        func then_should_call_api_create_with(_ experienceId: String, _ title: String,
                                              _ description: String, _ latitude: Double,
                                              _ longitude: Double) -> ScenarioMaker {
            assert(mockRepo.createScenceCalls.count == 1)
            assert(mockRepo.createScenceCalls[0].0 == experienceId)
            assert(mockRepo.createScenceCalls[0].1 == title)
            assert(mockRepo.createScenceCalls[0].2 == description)
            assert(mockRepo.createScenceCalls[0].3 == latitude)
            assert(mockRepo.createScenceCalls[0].4 == longitude)
            return self
        }

        @discardableResult
        func then_should_show_error() -> ScenarioMaker {
            assert(mockView.showErrorCalls == 1)
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
        func then_should_navigate_to_select_location(_ lat: Double?, _ lon: Double?) -> ScenarioMaker {
            assert(mockView.navigateToSelectLocationCalls.count == 1)
            assert(mockView.navigateToSelectLocationCalls[0].0 == lat)
            assert(mockView.navigateToSelectLocationCalls[0].1 == lon)
            return self
        }

        @discardableResult
        func then_should_show_no_location_error() -> ScenarioMaker {
            assert(mockView.showNoLocationErrorCalls == 1)
            return self
        }

        @discardableResult
        func then_should_try_to_find_last_known_location() -> ScenarioMaker {
            assert(mockView.tryToFindLastKnownLocationCalls == 1)
            return self
        }
    }
}

class CreateSceneViewMock: CreateSceneView {

    var titleResult = ""
    var descriptionResult = ""
    var pictureResult: UIImage?
    var latitudeResult: Double?
    var longitudeResult: Double?
    var lastKnowndLatitudeResult: Double?
    var lastKnowndLongitudeResult: Double?
    var showLoaderCalls = 0
    var hideLoaderCalls = 0
    var enableButtonCalls = 0
    var disableButtonCalls = 0
    var showErrorCalls = 0
    var showSuccessAndUploadingPictureCalls = 0
    var showTitleLengthErrorCalls = 0
    var showNoDescriptionErrorCalls = 0
    var showNoPictureErrorCalls = 0
    var navigateToPickAndCropImageCalls = 0
    var finishCalls = 0
    var showNoLocationErrorCalls = 0
    var navigateToSelectLocationCalls = [(Double?, Double?)]()
    var tryToFindLastKnownLocationCalls = 0

    func title() -> String { return titleResult }
    func description() -> String { return descriptionResult }
    func picture() -> UIImage? { return pictureResult }
    func showLoader() { showLoaderCalls += 1 }
    func hideLoader() { hideLoaderCalls += 1 }
    func enableCreateButton() { enableButtonCalls += 1 }
    func disableCreateButton() { disableButtonCalls += 1 }
    func showError() { showErrorCalls += 1 }
    func showSuccessAndUploadingPicture() { showSuccessAndUploadingPictureCalls += 1 }
    func showTitleLengthError() { showTitleLengthErrorCalls += 1 }
    func showNoDescriptionError() { showNoDescriptionErrorCalls += 1 }
    func showNoPictureError() { showNoPictureErrorCalls += 1 }
    func navigateToPickAndCropImage() { navigateToPickAndCropImageCalls += 1 }
    func finish() { finishCalls += 1 }
    func latitude() -> Double? { return latitudeResult }
    func longitude() -> Double? { return longitudeResult }
    func lastKnownLatitude() -> Double? { return lastKnowndLatitudeResult }
    func lastKnownLongitude() -> Double? { return lastKnowndLongitudeResult }
    func showNoLocationError() { showNoLocationErrorCalls += 1 }
    func tryToFindLastKnownLocation() { tryToFindLastKnownLocationCalls += 1 }
    func navigateToSelectLocation(_ initialLatitude: Double?,
                                  _ initialLongitude: Double?) {
        navigateToSelectLocationCalls.append((initialLatitude, initialLongitude))
    }
}
