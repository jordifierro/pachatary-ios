import UIKit
import CoreLocation

protocol CreateSceneView : class {
    func title() -> String
    func description() -> String
    func picture() -> UIImage?
    func latitude() -> Double?
    func longitude() -> Double?
    func lastKnownLatitude() -> Double?
    func lastKnownLongitude() -> Double?
    func tryToFindLastKnownLocation()
    func showLoader()
    func hideLoader()
    func enableCreateButton()
    func disableCreateButton()
    func showError()
    func showSuccessAndUploadingPicture()
    func showTitleLengthError()
    func showNoDescriptionError()
    func showNoPictureError()
    func showNoLocationError()
    func navigateToPickAndCropImage()
    func navigateToSelectLocation(_ initialLatitude: Double?, _ initialLongitude: Double?)
    func finish()
}

class CreateSceneViewController: UIViewController {

    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var selectLocationButton: UIButton!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var createButton: GreenButton!

    var presenter: CreateScenePresenter?
    var experienceId: String!
    var image: UIImage?
    var selectedLatitude: Double?
    var selectedLongitude: Double?
    var deviceLatitude: Double?
    var deviceLongitude: Double?
    var segueLatitude: Double?
    var segueLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "ADD SCENE"

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

        presenter = SceneDependencyInjector.createScenePresenter(view: self,
                                                                 experienceId: experienceId)

        createButton.addTarget(self, action: #selector(createButtonClick), for: .touchUpInside)
        addPictureButton.addTarget(self, action: #selector(addPictureButtonClick), for: .touchUpInside)
        selectLocationButton.addTarget(self, action: #selector(selectLocationButtonClick), for: .touchUpInside)
    }

    @objc func createButtonClick(_ sender: UIButton!) {
        presenter!.createButtonClick()
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
            if selectedLatitude != nil {
                destinationVC.initialLatitude = segueLatitude
                destinationVC.initialLongitude = segueLongitude
            }
        }
    }
}

extension CreateSceneViewController: CreateSceneView {

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

    func lastKnownLatitude() -> Double? {
        return deviceLatitude
    }

    func lastKnownLongitude() -> Double? {
        return deviceLongitude
    }

    func tryToFindLastKnownLocation() {
        let location = CLLocationManager().location
        if location != nil {
            deviceLatitude = location!.coordinate.latitude
            deviceLongitude = location!.coordinate.longitude
        }
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

    func navigateToSelectLocation(_ initialLatitude: Double?, _ initialLongitude: Double?) {
        segueLatitude = initialLatitude
        segueLongitude = initialLongitude
        performSegue(withIdentifier: "selectLocationSegue", sender: self)
    }

    func showError() {
        Snackbar.showError()
    }

    func showSuccessAndUploadingPicture() {
        Snackbar.show("Scene successfully created! Uploading image...", .long)
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

extension CreateSceneViewController: PickAndCropImageDelegate {
    func pickAndCropImageViewController(didFinishWith image: UIImage) {
        self.image = image
        pictureImageView.image = image
        pictureImageView.roundCornersForAspectFit(radius: 23)
    }
}

extension CreateSceneViewController: UITextViewDelegate {

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
