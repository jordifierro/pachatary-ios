import UIKit
import Kingfisher

class ProfileCollectionViewCell: UICollectionViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    func bind(_ profile: Profile) {
        if profile.picture != nil {
            let pictureUrl = PictureDeviceCompat.convert(profile.picture!).halfScreenSizeUrl
            pictureImageView.kf.setImage(with: URL(string: pictureUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        pictureImageView.layer.cornerRadius = 60
        pictureImageView.layer.masksToBounds = true
        usernameLabel.text = profile.username
        bioLabel.text = profile.bio
    }
}


