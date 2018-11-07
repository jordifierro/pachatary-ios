import UIKit
import Kingfisher

class SceneTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var navigateToSceneButton: UIButton!
    @IBOutlet weak var editSceneButton: UIButton!

    var gradientLayer: CAGradientLayer?
    var scene: Scene!
    var onLocateSceneClickListener: ((String) -> ())!
    var onEditSceneClickListener: ((String) -> ())!
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
              _ editSceneListener: @escaping (String) -> (),
              _ canEditScene: Bool,
              _ expandDescription: Bool) {
        self.scene = scene
        self.onLocateSceneClickListener = onLocateSceneClickListener
        self.onEditSceneClickListener = editSceneListener
        self.showMoreListener = showMoreListener
        if scene.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: scene.picture!.mediumUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
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

        editSceneButton.layer.cornerRadius = 20
        editSceneButton.layer.masksToBounds = true
        editSceneButton.addTarget(self, action: #selector(editSceneButtonClick), for: .touchUpInside)
        if canEditScene { editSceneButton.isHidden = false }
        else { editSceneButton.isHidden = true }

        setupGradientMask()
    }

    @objc func showMoreTap(sender: UITapGestureRecognizer) {
        self.showMoreListener(self.scene.id)
    }

    @objc func navigateToSceneButtonListener(_ sender: UIButton!) {
        self.onLocateSceneClickListener(self.scene.id)
    }

    @objc func editSceneButtonClick(_ sender: UIButton!) {
        self.onEditSceneClickListener(self.scene.id)
    }

    private func setupGradientMask() {
        if self.gradientLayer == nil {
            gradientLayer = CAGradientLayer.init(layer: self.pictureImageView.layer)
            gradientLayer!.frame = CGRect(x: 0, y: 0,
                                          width: self.bounds.width, height: self.bounds.width)
            gradientLayer!.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                     UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor]
            gradientLayer!.locations = [0.5, 1]
            gradientLayer!.zPosition = 1000
            self.pictureImageView.layer.addSublayer(gradientLayer!)
        }
    }
}
