import XCTest
import RxSwift
@testable import Pachatary

class PickAndCropImagePresenterTests: XCTestCase {

    func test_on_create_shows_image_picker() {
        ScenarioMaker()
            .when_create()
            .then_should_show_image_picker()
    }

    func test_on_image_selected_show_image_cropper() {
        let image = UIImage()
        ScenarioMaker()
            .when_image_selected(image)
            .then_should_show_image_cropper(image)
    }

    func test_on_image_selection_cancelled() {
        ScenarioMaker()
            .when_image_selection_cancelled()
            .then_should_finish()
    }

    func test_on_image_cropped_resizes_and_finishes() {
        let cropped = UIImage()
        let resized = UIImage()
        ScenarioMaker()
            .given_a_resized_image(resized)
            .when_image_cropped(cropped)
            .then_should_call_resize(cropped)
            .then_should_finish_with_image(resized)
    }

    func test_on_image_crop_cancelled_shows_image_picker() {
        ScenarioMaker()
            .when_image_crop_cancel()
            .then_should_show_image_picker()
    }

    class ScenarioMaker {
        let mockView = PickAndCropImageViewMock()
        var presenter: PickAndCropImagePresenter!

        init() {
            presenter = PickAndCropImagePresenter(mockView)
        }

        func given_a_resized_image(_ image: UIImage) -> ScenarioMaker {
            mockView.resizeImageIfTooBigResult = image
            return self
        }

        func when_create() -> ScenarioMaker {
            presenter.create()
            return self
        }

        func when_image_selected(_ image: UIImage) -> ScenarioMaker {
            presenter.imageSelected(image)
            return self
        }

        func when_image_selection_cancelled() -> ScenarioMaker {
            presenter.imageSelectionCanceled()
            return self
        }

        func when_image_cropped(_ image: UIImage) -> ScenarioMaker {
            presenter.imageCropped(image)
            return self
        }

        func when_image_crop_cancel() -> ScenarioMaker {
            presenter.imageCropCanceled()
            return self
        }

        @discardableResult
        func then_should_show_image_picker() -> ScenarioMaker {
            assert(mockView.showImagePickerCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_image_cropper(_ image: UIImage) -> ScenarioMaker {
            assert(mockView.showImageCropperCalls == [image])
            return self
        }

        @discardableResult
        func then_should_finish() -> ScenarioMaker {
            assert(mockView.finishCalls == 1)
            return self
        }

        @discardableResult
        func then_should_call_resize(_ image: UIImage) -> ScenarioMaker {
            assert(mockView.resizeImageIfTooBigCalls == [image])
            return self
        }

        @discardableResult
        func then_should_finish_with_image(_ image: UIImage) -> ScenarioMaker {
            assert(mockView.finishWithImageCalls == [image])
            return self
        }
    }
}

class PickAndCropImageViewMock: PickAndCropImageView {

    var showImagePickerCalls = 0
    var showImageCropperCalls = [UIImage]()
    var resizeImageIfTooBigCalls = [UIImage]()
    var resizeImageIfTooBigResult: UIImage!
    var finishWithImageCalls = [UIImage]()
    var finishCalls = 0

    func showImagePicker() {
        showImagePickerCalls += 1
    }

    func showImageCropper(_ image: UIImage) {
        showImageCropperCalls.append(image)
    }

    func resizeImageIfTooBig(_ image: UIImage) -> UIImage {
        resizeImageIfTooBigCalls.append(image)
        return resizeImageIfTooBigResult
    }

    func finish(with image: UIImage) {
        finishWithImageCalls.append(image)
    }

    func finish() {
        finishCalls += 1
    }
}
