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
            pictureImageView.kf.setImage(with: URL(string: profile.picture!.smallUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        pictureImageView.layer.cornerRadius = 70
        pictureImageView.layer.masksToBounds = true
        usernameLabel.text = profile.username
        bioLabel.text = profile.bio
    }
}


