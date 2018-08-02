import UIKit
import Kingfisher

class ExperienceDetailTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var savesCountLabel: UILabel!
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var goToMapButton: UIButton!
    var onGoToMapClickListener: (() -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(_ experience: Experience, _ onGoToMapClickListener: @escaping () -> Void) {
        self.onGoToMapClickListener = onGoToMapClickListener
        if experience.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: experience.picture!.mediumUrl))
        }
        titleLabel.text = experience.title
        savesCountLabel.text = String(experience.savesCount) + " ☆"
        authorUsernameLabel.text = "by " + experience.authorProfile.username
        descriptionLabel.text = experience.description
        goToMapButton.addTarget(self, action: #selector(goToMapButtonListener), for: .touchUpInside)
    }
    
    @objc func goToMapButtonListener(_ sender: UIButton!) {
        self.onGoToMapClickListener()
    }
}
