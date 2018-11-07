import UIKit
import Kingfisher
import MapboxStatic

class ExperienceDetailTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var savesCountLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var showMoreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!

    var gradientLayer: CAGradientLayer?
    var experience: Experience!
    var onGoToMapClickListener: (() -> ())!
    var profileClickListener: ((String) -> ())!
    var showMoreListener: (() -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapImageView.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(goToMapButtonListener(_:)))
        singleTap.numberOfTapsRequired = 1;
        mapImageView.addGestureRecognizer(singleTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(_ experience: Experience, _ scenes: [Scene],
              _ onGoToMapClickListener: @escaping () -> Void,
              _ saveButtonListener: @escaping (Bool) -> (),
              _ profileClickListener: @escaping (String) -> (),
              _ showMoreListener: @escaping () -> (),
              _ expandDescription: Bool) {
        self.onGoToMapClickListener = onGoToMapClickListener
        self.profileClickListener = profileClickListener
        self.experience = experience
        self.showMoreListener = showMoreListener
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
        authorUsernameLabel.text = experience.authorProfile.username
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(ExperienceDetailTableViewCell.profileTap))
        authorImageView.isUserInteractionEnabled = true
        authorImageView.addGestureRecognizer(imageTap)
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(ExperienceDetailTableViewCell.profileTap))
        authorUsernameLabel.isUserInteractionEnabled = true
        authorUsernameLabel.addGestureRecognizer(labelTap)

        starImageView.image = starImageView.image!.withRenderingMode(.alwaysTemplate)
        if experience.isSaved { starImageView.tintColor = UIColor.themeGreen }
        else { starImageView.tintColor = UIColor.gray }

        titleLabel.text = experience.title
        savesCountLabel.text = String(experience.savesCount)
        descriptionLabel.text = experience.description
        if (!scenes.isEmpty) {
            let screenWidth = UIScreen.main.bounds.width
            let options = SnapshotOptions(
                styleURL: URL(string: "mapbox://styles/mapbox/light-v9")!,
                size: CGSize(width: screenWidth, height: screenWidth/2))
            for scene in scenes {
                let customMarker = CustomMarker(
                    coordinate: CLLocationCoordinate2D(latitude: scene.latitude,
                                                       longitude: scene.longitude),
                    url: URL(string:
                        "https://s3-eu-west-1.amazonaws.com/pachatary/static/circle.png")!)
                options.overlays.append(customMarker)
            }
            let snapshot = Snapshot(
                options: options,
                accessToken: AppDataDependencyInjector.mapboxAccessToken)
            mapImageView.image = snapshot.image
        }

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
            if !descriptionLabel.isTruncated { showMoreLabel.isHidden = true }
            else { showMoreLabel.isHidden = false }
        }

        setupGradientMask()
    }

    @objc func showMoreTap(sender: UITapGestureRecognizer) {
        self.showMoreListener()
    }

    @objc func goToMapButtonListener(_ sender: UIButton!) {
        self.onGoToMapClickListener()
    }

    @objc func profileTap(sender: UITapGestureRecognizer) {
        profileClickListener(self.experience.authorProfile.username)
    }

    private func setupGradientMask() {
        if self.gradientLayer == nil {
            gradientLayer = CAGradientLayer.init(layer: self.pictureImageView.layer)
            gradientLayer!.frame = self.pictureImageView.bounds
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
