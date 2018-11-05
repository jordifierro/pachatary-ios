import UIKit
import CropViewController

protocol PickAndCropImageView : class {
    func showImagePicker()
    func showImageCropper(_ image: UIImage)
    func resizeImageIfTooBig(_ image: UIImage) -> UIImage
    func finish(with image: UIImage)
    func finish()
}

protocol PickAndCropImageDelegate {
    func pickAndCropImageViewController(didFinishWith image: UIImage)
}

class PickAndCropImageViewController: UIViewController {

    let maxImageSize = 1600

    var presenter: PickAndCropImagePresenter?
    var delegate: PickAndCropImageDelegate?
    var firstTime = true

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = PickAndCropImagePresenter(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        if firstTime {
            firstTime = false
            presenter!.create()
        }
    }
}

extension PickAndCropImageViewController: PickAndCropImageView {

    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.modalTransitionStyle = .crossDissolve
        imagePicker.popoverPresentationController?.delegate = self
        imagePicker.popoverPresentationController?.sourceView = view
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: .highlighted)
        present(imagePicker, animated: true, completion: nil)
    }

    func showImageCropper(_ image: UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.aspectRatioPreset = .presetSquare
        present(cropViewController, animated: true, completion: nil)
    }

    func resizeImageIfTooBig(_ image: UIImage) -> UIImage {
        var ratio = 1
        var width = Int(image.size.width)
        while width > maxImageSize {
            width /= 2
            ratio *= 2
        }
        if ratio == 1 { return image }
        else {
            let newSize = CGSize(width: image.size.width / CGFloat(ratio),
                                 height: image.size.height / CGFloat(ratio))
            let rect = CGRect(x: 0, y: 0,
                              width: newSize.width, height: newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
    }

    func finish(with image: UIImage) {
        delegate!.pickAndCropImageViewController(didFinishWith: image)
        finish()
    }

    func finish() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: UIControlState.highlighted)

        self.navigationController?.popViewController(animated: true)
    }
}

extension PickAndCropImageViewController : UINavigationControllerDelegate,
                                           UIImagePickerControllerDelegate,
                                           UIPopoverPresentationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        presenter!.imageSelectionCanceled()
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            presenter!.imageSelected(editedImage)
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            presenter!.imageSelected(originalImage)
        }
        else {
            presenter!.imageSelectionCanceled()
        }
    }

    func popoverPresentationControllerDidDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController) {
        view.alpha = 1.0
    }
}

extension PickAndCropImageViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController,
                            didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        presenter!.imageCropped(image)
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
        presenter!.imageCropCanceled()
    }
}
