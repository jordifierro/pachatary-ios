import XCTest
import RxSwift
@testable import Pachatary

class EditExperiencePresenterTests: XCTestCase {

    enum Action {
        case create
        case retry
    }

    func test_create_response_inprogress() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("4")
                .given_a_repo_that_returns_on_experience(Result(.inProgress))
                .when_do(action)
                .then_should_call_repo_experience("4")
                .then_should_disable_button()
                .then_should_show_loader()
        }
    }

    func test_create_response_error() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("4")
                .given_a_repo_that_returns_on_experience(
                    Result(.error, error: DataError.noInternetConnection))
                .when_do(action)
                .then_should_call_repo_experience("4")
                .then_should_disable_button()
                .then_should_hide_loader()
                .then_should_show_retry()
        }
    }

    func test_create_response_success() {
        for action in [Action.create, Action.retry] {
            ScenarioMaker()
                .given_a_presenter("4")
                .given_a_repo_that_returns_on_experience(Result(.success, data: Mock.experience("4")))
                .when_do(action)
                .then_should_call_repo_experience("4")
                .then_should_enable_button()
                .then_should_hide_loader()
                .then_should_fill_experience_data(Mock.experience("4"))
        }
    }

    func test_update_with_no_title_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .when_update_button_click()
            .then_should_show_title_length_error()
    }

    func test_update_with_long_title_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_title(String(repeating: "5", count: 81))
            .when_update_button_click()
            .then_should_show_title_length_error()
    }

    func test_update_with_no_description_shows_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_title("t")
            .when_update_button_click()
            .then_should_show_no_description_error()
    }

    func test_update_experience_response_inprogress() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.inProgress))
            .when_update_button_click()
            .then_should_disable_button()
            .then_should_show_loader()
    }

    func test_update_experience_response_error() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(UIImage())
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.error, error: DataError.noInternetConnection))
            .when_update_button_click()
            .then_should_enable_button()
            .then_should_hide_loader()
            .then_should_show_error()
    }

    func test_update_experience_response_success_without_new_picture() {
        ScenarioMaker()
            .given_a_presenter("4")
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.success, data: Mock.experience("85")))
            .when_update_button_click()
            .then_should_call_repo_edit("4", "t", "d")
            .then_should_show_success()
            .then_should_finish()
    }

    func test_update_experience_response_success_with_new_picture() {
        let pic = UIImage()
        ScenarioMaker()
            .given_a_presenter("4")
            .given_an_picture(pic)
            .given_a_title("t")
            .given_a_description("d")
            .given_a_repo_that_returns(Result(.success, data: Mock.experience("85")))
            .when_update_button_click()
            .then_should_call_repo_edit("4", "t", "d")
            .then_should_show_success_and_uploading_picture()
            .then_should_finish()
            .then_should_call_repo_upload_picture_with("4", pic)
    }

    class ScenarioMaker {
        let mockView = EditExperienceViewMock()
        let mockRepo = ExperienceRepoMock()
        var presenter: EditExperiencePresenter!

        func given_a_presenter(_ experienceId: String) -> ScenarioMaker {
            presenter = EditExperiencePresenter(mockRepo, MainScheduler.instance,
                                                mockView, experienceId)
            return self
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
            mockRepo.editExperienceResult = Observable.just(result)
            return self
        }

        func given_a_repo_that_returns_on_experience(_ result: Result<Experience>) -> ScenarioMaker {
            mockRepo.returnExperienceObservable = Observable.just(result)
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
        func then_should_call_repo_upload_picture_with(_ experienceId: String,
                                                       _ image: UIImage) -> ScenarioMaker {
            assert(mockRepo.uploadPictureCalls.count == 1)
            assert(mockRepo.uploadPictureCalls[0].0 == experienceId)
            assert(mockRepo.uploadPictureCalls[0].1 == image)
            return self
        }

        @discardableResult
        func then_should_call_repo_edit(_ experienceId: String, _ title: String,
                                        _ description: String) -> ScenarioMaker {
            assert(mockRepo.editExperienceCalls.count == 1)
            assert(mockRepo.editExperienceCalls[0].0 == experienceId)
            assert(mockRepo.editExperienceCalls[0].1 == title)
            assert(mockRepo.editExperienceCalls[0].2 == description)
            return self
        }

        @discardableResult
        func then_should_call_repo_experience(_ experienceId: String) -> ScenarioMaker {
            assert(mockRepo.singleExperienceCalls == [experienceId])
            return self
        }

        @discardableResult
        func then_should_fill_experience_data(_ experience: Experience) -> ScenarioMaker {
            assert(mockView.fillExperienceDataCalls == [experience])
            return self
        }
    }
}

class EditExperienceViewMock: EditExperienceView {

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
    var fillExperienceDataCalls = [Experience]()

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
    func fillExperienceData(_ experience: Experience) { fillExperienceDataCalls.append(experience) }
}
