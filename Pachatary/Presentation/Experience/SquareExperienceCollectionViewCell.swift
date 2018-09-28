import UIKit
import Kingfisher

class SquareExperienceCollectionViewCell: UICollectionViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(_ experience: Experience) {
        if experience.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: experience.picture!.smallUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        titleLabel.text = experience.title
    }
}


