import UIKit
import Kingfisher

class ExtendedExperienceTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var savesCountLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    var gradientLayer: CAGradientLayer? = nil
    var profileClickListener: ((String) -> ())!
    var username: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(_ experience: Experience, _ profileClickListener: @escaping (String) -> ()) {
        self.profileClickListener = profileClickListener
        self.username = experience.authorProfile.username
        if experience.picture != nil {
            let pictureUrl = PictureDeviceCompat.convert(experience.picture!).fullScreenSizeUrl
            pictureImageView.kf.setImage(with: URL(string: pictureUrl))
        }
        else { pictureImageView.kf.setImage(with: nil) }
        if experience.authorProfile.picture != nil {
            let pictureUrl = PictureDeviceCompat
                .convert(experience.authorProfile.picture!).iconSizeUrl
            authorImageView.kf.setImage(with: URL(string: pictureUrl))
        }
        else { authorImageView.kf.setImage(with: nil) }
        authorImageView.layer.cornerRadius = 24
        authorImageView.layer.masksToBounds = true
        titleLabel.text = experience.title
        descriptionLabel.text = experience.description
        savesCountLabel.text = String(experience.savesCount)
        authorUsernameLabel.text = experience.authorProfile.username
        starImageView.image = starImageView.image!.withRenderingMode(.alwaysTemplate)
        if experience.isSaved { starImageView.tintColor = UIColor.themeGreen }
        else { starImageView.tintColor = UIColor.gray }

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
