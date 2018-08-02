import UIKit
import Kingfisher

class SceneTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(_ scene: Scene) {
        if scene.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: scene.picture!.mediumUrl))
        }
        titleLabel.text = scene.title
        descriptionLabel.text = scene.description
    }
}


