import UIKit
import Kingfisher

class SceneTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var navigateToSceneButton: UIButton!

    var gradientLayer: CAGradientLayer?
    var scene: Scene!
    var onLocateSceneClickListener: ((String) -> ())!
    var showMoreListener: ((String) -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(_ scene: Scene, _ onLocateSceneClickListener: @escaping (String) -> (),
              _ showMoreListener: @escaping (String) -> (),
              _ expandDescription: Bool) {
        self.scene = scene
        self.onLocateSceneClickListener = onLocateSceneClickListener
        self.showMoreListener = showMoreListener
        if scene.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: scene.picture!.mediumUrl))
        }
        titleLabel.text = scene.title
        descriptionLabel.text = scene.description
        navigateToSceneButton.addTarget(self, action: #selector(navigateToSceneButtonListener),
                                        for: .touchUpInside)
        navigateToSceneButton.layer.cornerRadius = 20
        navigateToSceneButton.layer.masksToBounds = true

        if expandDescription {
            showMoreLabel.isHidden = true
            descriptionLabel.numberOfLines = 0
        }
        else {
            let showMoreLabelTap = UITapGestureRecognizer(target: self, action: #selector(ExperienceDetailTableViewCell.showMoreTap))
            showMoreLabel.isHidden = false
            showMoreLabel.isUserInteractionEnabled = true
            showMoreLabel.addGestureRecognizer(showMoreLabelTap)
            descriptionLabel.numberOfLines = 4
        }

        setupGradientMask()
    }

    @objc func showMoreTap(sender: UITapGestureRecognizer) {
        self.showMoreListener(self.scene.id)
    }

    @objc func navigateToSceneButtonListener(_ sender: UIButton!) {
        self.onLocateSceneClickListener(self.scene.id)
    }

    private func setupGradientMask() {
        if self.gradientLayer == nil {
            gradientLayer = CAGradientLayer.init(layer: self.pictureImageView.layer)
            gradientLayer!.frame = self.pictureImageView.bounds;
            gradientLayer!.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                     UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor]
            gradientLayer!.locations = [0.5, 1]
            gradientLayer!.zPosition = 1000
            self.pictureImageView.layer.addSublayer(gradientLayer!)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradientLayer?.frame = self.pictureImageView.bounds
    }
}


