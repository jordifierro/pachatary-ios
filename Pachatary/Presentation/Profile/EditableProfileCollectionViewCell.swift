import UIKit
import Kingfisher

class EditableProfileCollectionViewCell: UICollectionViewCell {

    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var editPictureButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    var onEditPictureListener: (() -> ())!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func bind(_ profile: Profile, _ onEditPictureListener: @escaping () -> ()) {
        self.onEditPictureListener = onEditPictureListener
        editPictureButton.addTarget(self, action: #selector(editPictureButtonClick),
                                    for: .touchUpInside)

        if profile.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: profile.picture!.smallUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        pictureImageView.layer.cornerRadius = 60
        pictureImageView.layer.masksToBounds = true
        editPictureButton.layer.cornerRadius = 60
        editPictureButton.layer.masksToBounds = true
        usernameLabel.text = profile.username
        //bioLabel.text = profile.bio
    }

    @objc func editPictureButtonClick(_ sender: UIButton!) {
        self.onEditPictureListener()
    }
}
