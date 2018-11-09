import UIKit
import Kingfisher

class SquareExperienceCollectionViewCell: UICollectionViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var gradientLayer: CAGradientLayer? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(_ experience: Experience) {
        if experience.picture != nil {
            let pictureUrl = PictureDeviceCompat.convert(experience.picture!).halfScreenSizeUrl
            pictureImageView.kf.setImage(with: URL(string: pictureUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        titleLabel.text = experience.title
    }
}
