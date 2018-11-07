import UIKit
import Kingfisher

class EditableProfileCollectionViewCell: UICollectionViewCell {

    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var editPictureButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!

    var onEditPictureListener: (() -> ())!
    var onEditBioListener: ((String) -> ())!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(_ profile: Profile,
              _ onEditPictureListener: @escaping () -> (),
              _ onEditBioListener: @escaping (String) -> ()) {
        self.onEditPictureListener = onEditPictureListener
        self.onEditBioListener = onEditBioListener
        editPictureButton.addTarget(self, action: #selector(editPictureButtonClick),
                                    for: .touchUpInside)

        if profile.picture != nil {
            let pictureUrl = PictureDeviceCompat.convert(profile.picture!).halfScreenSizeUrl
            pictureImageView.kf.setImage(with: URL(string: pictureUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        pictureImageView.layer.cornerRadius = 60
        pictureImageView.layer.masksToBounds = true
        editPictureButton.layer.cornerRadius = 60
        editPictureButton.layer.masksToBounds = true
        usernameLabel.text = profile.username

        if profile.bio.isEmpty {
            bioTextView.textColor = UIColor.themeGreen
            bioTextView.text = "Tap to add your bio"
        }
        else {
            bioTextView.textColor = UIColor.black
            bioTextView.text = profile.bio
        }
        bioTextView.textContainer.maximumNumberOfLines = 3
        bioTextView.delegate = self
    }

    @objc func editPictureButtonClick(_ sender: UIButton!) {
        self.onEditPictureListener()
    }
}

extension EditableProfileCollectionViewCell: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.themeGreen {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.onEditBioListener(textView.text!)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return textView.text.count + (text.count - range.length) <= 140
    }
}
