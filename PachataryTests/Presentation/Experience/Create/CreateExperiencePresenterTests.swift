import XCTest
import RxSwift
@testable import Pachatary

class CreateExperiencePresenterTests: XCTestCase {

    func test_no_image_shows_error() {
        ScenarioMaker()
            .when_create_button_click()
            .then_should_show_no_image_error()
    }

    func test_no_title_shows_error() {
        ScenarioMaker()
            .given_an_picture(UIImage())
            .when_create_button_click()
            .then_should_show_title_length_error()
    }

    func test_long_title_shows_error() {
        ScenarioMaker()
            .given_an_picture(UIImage())
            .given_a_title(String(repeating: "5", count: 81))
            .when_create_button_click()
            .then_should_show_title_length_error()
    }

    func test_no_description_shows_error() {
        ScenarioMaker()
            .given_an_picture(UIImage())
            .given_a_title("t")
            .when_create_button_click()
            .then_should_show_no_description_error()
    }

    func test_create_experience_response_inprogress() {
        ScenarioMaker()
            .given_an_picture(UIImage())
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.inProgress))
            .when_create_button_click()
            .then_should_disable_button()
            .then_should_show_loader()
    }

    func test_create_experience_response_error() {
        ScenarioMaker()
            .given_an_picture(UIImage())
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.error, error: DataError.noInternetConnection))
            .when_create_button_click()
            .then_should_enable_button()
            .then_should_hide_loader()
            .then_should_show_error()
    }

    func test_create_experience_response_success() {
        let pic = UIImage()
        ScenarioMaker()
            .given_an_picture(pic)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.success, data: Mock.experience("85")))
            .when_create_button_click()
            .then_should_show_success_and_uploading_picture()
            .then_should_finish()
            .then_should_call_repo_upload_picture_with("85", pic)
    }

    class ScenarioMaker {
        let mockView = CreateExperienceViewMock()
        let mockRepo = ExperienceRepoMock()
        var presenter: CreateExperiencePresenter!

        init() {
            presenter = CreateExperiencePresenter(mockRepo, MainScheduler.instance, mockView)
        }

        func given_an_picture(_ image: UIImage) -> ScenarioMaker {
            mockView.pictureResult = image
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

        func given_a_repo_that_returns(_ result: Result<Experience>) -> ScenarioMaker {
            mockRepo.createExperienceResult = Observable.just(result)
            return self
        }

        func when_create_button_click() -> ScenarioMaker {
            presenter.createButtonClick()
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
        func then_should_call_repo_upload_picture_with(_ experienceId: String,
                                                       _ image: UIImage) -> ScenarioMaker {
            assert(mockRepo.uploadPictureCalls.count == 1)
            assert(mockRepo.uploadPictureCalls[0].0 == experienceId)
            assert(mockRepo.uploadPictureCalls[0].1 == image)
            return self
        }
    }
}

class CreateExperienceViewMock: CreateExperienceView {

    var titleResult = ""
    var descriptionResult = ""
    var pictureResult: UIImage?
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
}
