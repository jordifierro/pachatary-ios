import UIKit

protocol CreateExperienceView : class {
    func title() -> String
    func description() -> String
    func picture() -> UIImage?
    func showLoader()
    func hideLoader()
    func enableCreateButton()
    func disableCreateButton()
    func showError()
    func showSuccessAndUploadingPicture()
    func showTitleLengthError()
    func showNoDescriptionError()
    func showNoPictureError()
    func navigateToPickAndCropImage()
    func finish()
}

class CreateExperienceViewController: UIViewController {

    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var createButton: GreenButton!

    var presenter: CreateExperiencePresenter?
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "NEW EXPERIENCE"

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

        presenter = ExperienceDependencyInjector.createExperiencePresenter(view: self)

        createButton.addTarget(self, action: #selector(createButtonClick), for: .touchUpInside)
        addPictureButton.addTarget(self, action: #selector(addPictureButtonClick), for: .touchUpInside)
    }

    @objc func createButtonClick(_ sender: UIButton!) {
        presenter!.createButtonClick()
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

extension CreateExperienceViewController: CreateExperienceView {

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

    func enableCreateButton() {
        createButton.isEnabled = true
    }

    func disableCreateButton() {
        createButton.isEnabled = false
    }

    func navigateToPickAndCropImage() {
        performSegue(withIdentifier: "pickAndCropImageSegue", sender: self)
    }

    func showError() {
        Snackbar.showError()
    }

    func showSuccessAndUploadingPicture() {
        Snackbar.show("Experience successfully created! Uploading image...", .long)
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

extension CreateExperienceViewController: PickAndCropImageDelegate {
    func pickAndCropImageViewController(didFinishWith image: UIImage) {
        self.image = image
        pictureImageView.image = image
        pictureImageView.roundCornersForAspectFit(radius: 23)
    }
}

extension CreateExperienceViewController: UITextViewDelegate {

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
}
