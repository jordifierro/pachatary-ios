import UIKit
import Kingfisher

class ExtendedExperienceTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var savesCountLabel: UILabel!
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var profileClickListener: ((String) -> ())!
    var username: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(_ experience: Experience, _ profileClickListener: @escaping (String) -> ()) {
        self.profileClickListener = profileClickListener
        self.username = experience.authorProfile.username
        if experience.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: experience.picture!.mediumUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        if experience.authorProfile.picture != nil {
            authorImageView.kf.setImage(with: URL(string: experience.authorProfile.picture!.smallUrl))
        }
        else { authorImageView.kf.setImage(with: nil) }
        authorImageView.layer.cornerRadius = 20
        authorImageView.layer.masksToBounds = true
        titleLabel.text = experience.title
        descriptionLabel.text = experience.description
        savesCountLabel.text = String(experience.savesCount) + " ☆"
        authorUsernameLabel.text = experience.authorProfile.username

        let labelTap = UITapGestureRecognizer(target: self, action: #selector(ExtendedExperienceTableViewCell.profileTap))
        authorUsernameLabel.isUserInteractionEnabled = true
        authorUsernameLabel.addGestureRecognizer(labelTap)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(ExtendedExperienceTableViewCell.profileTap))
        authorImageView.isUserInteractionEnabled = true
        authorImageView.addGestureRecognizer(imageTap)
    }

    @objc func profileTap(sender: UITapGestureRecognizer) {
        profileClickListener(username)
    }
}
