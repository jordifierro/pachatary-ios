import UIKit
import CoreLocation

protocol EditSceneView : class {
    func title() -> String
    func description() -> String
    func picture() -> UIImage?
    func latitude() -> Double?
    func longitude() -> Double?
    func fillSceneData(_ scene: Scene)
    func showRetry()
    func showLoader()
    func hideLoader()
    func enableUpdateButton()
    func disableUpdateButton()
    func showError()
    func showSuccess()
    func showSuccessAndUploadingPicture()
    func showTitleLengthError()
    func showNoDescriptionError()
    func showNoPictureError()
    func showNoLocationError()
    func navigateToPickAndCropImage()
    func navigateToSelectLocation()
    func finish()
}

class EditSceneViewController: UIViewController {

    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var selectLocationButton: UIButton!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var updateButton: GreenButton!

    var presenter: EditScenePresenter?
    var experienceId: String!
    var sceneId: String!
    var image: UIImage?
    var selectedLatitude: Double?
    var selectedLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "EDIT SCENE"

        addPictureButton.layer.cornerRadius = 23
        pictureImageView.layer.cornerRadius = 23
        selectLocationButton.layer.cornerRadius = 23
        titleTextView.layer.cornerRadius = 23
        titleTextView.textColor = UIColor.lightGray
        titleTextView.textContainerInset = UIEdgeInsetsMake(15, 10, 0, 10)
        titleTextView.delegate = self
        descriptionTextView.layer.cornerRadius = 23
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(15, 10, 0, 10)
        descriptionTextView.delegate = self

        presenter = SceneDependencyInjector.editScenePresenter(view: self,
                                                               experienceId: experienceId,
                                                               sceneId: sceneId)

        updateButton.addTarget(self, action: #selector(updateButtonClick), for: .touchUpInside)
        addPictureButton.addTarget(self, action: #selector(addPictureButtonClick), for: .touchUpInside)
        selectLocationButton.addTarget(self, action: #selector(selectLocationButtonClick), for: .touchUpInside)

        presenter!.create()
    }

    @objc func updateButtonClick(_ sender: UIButton!) {
        presenter!.updateButtonClick()
    }

    @objc func addPictureButtonClick(_ sender: UIButton!) {
        presenter!.addPictureButtonClick()
    }

    @objc func selectLocationButtonClick(_ sender: UIButton!) {
        presenter!.selectLocationButtonClick()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickAndCropImageSegue" {
            let destinationVC = segue.destination as! PickAndCropImageViewController
            destinationVC.delegate = self
        }
        else if segue.identifier == "selectLocationSegue" {
            let destinationVC = segue.destination as! SelectLocationViewController
            destinationVC.zoomLevel = SelectLocationViewController.ZoomLevel.street
            destinationVC.setResultDelegate = { [unowned self] (latitude, longitude) in
                self.selectedLatitude = latitude
                self.selectedLongitude = longitude
            }
            destinationVC.initialLatitude = selectedLatitude
            destinationVC.initialLongitude = selectedLongitude
        }
    }
}

extension EditSceneViewController: EditSceneView {

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

    func latitude() -> Double? {
        return selectedLatitude
    }

    func longitude() -> Double? {
        return selectedLongitude
    }

    func fillSceneData(_ scene: Scene) {
        titleTextView.text = scene.title
        titleTextView.textColor = UIColor.black
        descriptionTextView.text = scene.description
        descriptionTextView.textColor = UIColor.black
        if scene.picture == nil {
            pictureImageView.backgroundColor = UIColor.clear
        }
        else {
            pictureImageView.backgroundColor = UIColor.white
            pictureImageView.kf.setImage(with: URL(string: scene.picture!.smallUrl))
            pictureImageView.roundCornersForAspectFit(radius: 23)
        }
        selectedLatitude = scene.latitude
        selectedLongitude = scene.longitude
    }

    func showRetry() {
        Snackbar.showErrorWithRetry { [unowned self] () in self.presenter!.retry() }
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

    func navigateToSelectLocation() {
        performSegue(withIdentifier: "selectLocationSegue", sender: self)
    }

    func showError() {
        Snackbar.showError()
    }

    func showSuccess() {
        Snackbar.show("Scene successfully updated!", .short)
    }

    func showSuccessAndUploadingPicture() {
        Snackbar.show("Scene successfully updated! Uploading image...", .long)
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

    func showNoLocationError() {
        Snackbar.show("Select a location", .short)
    }

    func finish() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditSceneViewController: PickAndCropImageDelegate {
    func pickAndCropImageViewController(didFinishWith image: UIImage) {
        self.image = image
        pictureImageView.image = image
        pictureImageView.roundCornersForAspectFit(radius: 23)
    }
}

extension EditSceneViewController: UITextViewDelegate {

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
            if textView == titleTextView { textView.text = "Scene title..." }
            else if textView == descriptionTextView { textView.text = "Description..." }
        }
    }
}
