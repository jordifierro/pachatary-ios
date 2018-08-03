import UIKit
import Kingfisher

class SceneTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var navigateToSceneButton: UIButton!
    var scene: Scene!
    var onLocateSceneClickListener: ((String) -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(_ scene: Scene, _ onLocateSceneClickListener: @escaping (String) -> ()) {
        self.scene = scene
        self.onLocateSceneClickListener = onLocateSceneClickListener
        if scene.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: scene.picture!.mediumUrl))
        }
        titleLabel.text = scene.title
        descriptionLabel.text = scene.description
        navigateToSceneButton.addTarget(self, action: #selector(navigateToSceneButtonListener),
                                        for: .touchUpInside)
    }
    
    @objc func navigateToSceneButtonListener(_ sender: UIButton!) {
        self.onLocateSceneClickListener(self.scene.id)
    }
}


