import UIKit
import Kingfisher
import MapboxStatic

class ExperienceDetailTableViewCell: UITableViewCell {
    
    //Mark: PROPERTIES
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var savesCountLabel: UILabel!
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    var onGoToMapClickListener: (() -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(_ experience: Experience, _ scenes: [Scene],
              _ onGoToMapClickListener: @escaping () -> Void) {
        self.onGoToMapClickListener = onGoToMapClickListener
        if experience.picture != nil {
            pictureImageView.kf.setImage(with: URL(string: experience.picture!.mediumUrl))
        }
        titleLabel.text = experience.title
        savesCountLabel.text = String(experience.savesCount) + " ☆"
        authorUsernameLabel.text = "by " + experience.authorProfile.username
        descriptionLabel.text = experience.description
        mapImageView.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(goToMapButtonListener(_:)))
        singleTap.numberOfTapsRequired = 1;
        mapImageView.addGestureRecognizer(singleTap)
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
    }
    
    @objc func goToMapButtonListener(_ sender: UIButton!) {
        self.onGoToMapClickListener()
    }
}
