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

        setupGradientMask()
    }

    func setupGradientMask() {
        if self.gradientLayer == nil {
            gradientLayer = CAGradientLayer.init(layer: self.pictureImageView.layer)
            gradientLayer!.frame = self.pictureImageView.bounds;
            gradientLayer!.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                     UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor,
                                     UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
            gradientLayer!.locations = [0, 0.5, 1]
            gradientLayer!.zPosition = 1000
            self.pictureImageView.layer.addSublayer(gradientLayer!)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradientLayer?.frame = convert(pictureImageView.frame, to: pictureImageView)
    }
}
