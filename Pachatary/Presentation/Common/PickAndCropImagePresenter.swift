import UIKit

class PickAndCropImagePresenter {

    unowned let view: PickAndCropImageView

    init(_ view: PickAndCropImageView) {
        self.view = view
    }

    func create() {
        view.showImagePicker()
    }

    func imageSelected(_ image: UIImage) {
        view.showImageCropper(image)
    }

    func imageSelectionCanceled() {
        view.finish()
    }

    func imageCropped(_ image: UIImage) {
        view.finish(with: view.resizeImageIfTooBig(image))
    }

    func imageCropCanceled() {
        view.showImagePicker()
    }
}
