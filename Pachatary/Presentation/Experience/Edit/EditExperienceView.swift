import UIKit

protocol EditExperienceView : class {
    func title() -> String
    func description() -> String
    func picture() -> UIImage?
    func showLoader()
    func hideLoader()
    func enableUpdateButton()
    func disableUpdateButton()
    func showError()
    func showSuccessAndUploadingPicture()
    func showSuccess()
    func showTitleLengthError()
    func showNoDescriptionError()
    func showNoPictureError()
    func navigateToPickAndCropImage()
    func finish()
    func showRetry()
    func fillExperienceData(_ experience: Experience)
}

class EditExperienceViewController: UIViewController {

    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var updateButton: GreenButton!
    
    var presenter: EditExperiencePresenter?
    var experienceId: String!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "EDIT EXPERIENCE"

        addPictureButton.layer.cornerRadius = 23
        pictureImageView.layer.cornerRadius = 23
        titleTextView.layer.cornerRadius = 23
        titleTextView.textColor = UIColor.lightGray
        titleTextView.textContainerInset = UIEdgeInsetsMake(15, 10, 0, 10)
        titleTextView.delegate = self
        descriptionTextView.layer.cornerRadius = 23
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(15, 10, 0, 10)
        descriptionTextView.delegate = self

        presenter = ExperienceDependencyInjector.editExperiencePresenter(view: self,
                                                                         experienceId: experienceId)

        updateButton.addTarget(self, action: #selector(updateButtonClick), for: .touchUpInside)
        addPictureButton.addTarget(self, action: #selector(addPictureButtonClick), for: .touchUpInside)

        presenter!.create()
    }

    @objc func updateButtonClick(_ sender: UIButton!) {
        presenter!.updateButtonClick()
    }

    @objc func addPictureButtonClick(_ sender: UIButton!) {
        presenter!.addPictureButtonClick()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickAndCropImageSegue" {
            let destinationVC = segue.destination as! PickAndCropImageViewController
            destinationVC.delegate = self
        }
    }
}

extension EditExperienceViewController: EditExperienceView {

    func title() -> String {
        if titleTextView.textColor == UIColor.lightGray { return "" }
        return titleTextView.text
    }

    func description() -> String {
        if descriptionTextView.textColor == UIColor.lightGray { return "" }
        return descriptionTextView.text
    }

    func picture() -> UIImage? {
        return image
    }

    func showLoader() {
        activityIndicator.startAnimating()
    }

    func hideLoader() {
        activityIndicator.stopAnimating()
    }

    func enableUpdateButton() {
        updateButton.isEnabled = true
    }

    func disableUpdateButton() {
        updateButton.isEnabled = false
    }

    func navigateToPickAndCropImage() {
        performSegue(withIdentifier: "pickAndCropImageSegue", sender: self)
    }

    func showError() {
        Snackbar.showError()
    }

    func showSuccessAndUploadingPicture() {
        Snackbar.show("Experience successfully updated! Uploading image...", .long)
    }

    func showSuccess() {
        Snackbar.show("Experience successfully updated!", .short)
    }

    func showTitleLengthError() {
        Snackbar.show("Title must be between 1 and 80 characters", .short)
    }

    func showNoDescriptionError() {
        Snackbar.show("Description cannot be empty", .short)
    }

    func showNoPictureError() {
        Snackbar.show("Select a picture", .short)
    }

    func finish() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditExperienceViewController: PickAndCropImageDelegate {
    func pickAndCropImageViewController(didFinishWith image: UIImage) {
        self.image = image
        pictureImageView.image = image
        pictureImageView.roundCornersForAspectFit(radius: 23)
    }
}

extension EditExperienceViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == titleTextView {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return textView.text.count + (text.count - range.length) <= 80
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            if textView == titleTextView { textView.text = "Experience title..." }
            else if textView == descriptionTextView { textView.text = "Description..." }
        }
    }

    func showRetry() {
        Snackbar.showErrorWithRetry { [unowned self] () in self.presenter!.retry() }
    }

    func fillExperienceData(_ experience: Experience) {
        titleTextView.text = experience.title
        titleTextView.textColor = UIColor.black
        descriptionTextView.text = experience.description
        descriptionTextView.textColor = UIColor.black
        if experience.picture == nil {
            pictureImageView.backgroundColor = UIColor.clear
        }
        else {
            pictureImageView.backgroundColor = UIColor.white
            pictureImageView.kf.setImage(with: URL(string: experience.picture!.smallUrl))
            pictureImageView.roundCornersForAspectFit(radius: 23)
        }
    }

}
