import UIKit
import Mapbox

protocol SelectLocationView {
    func latitude() -> Double
    func longitude() -> Double
    func finishWith(latitude: Double, longitude: Double)
}

class SelectLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MGLMapView!

    var experienceId: String!
    var setResultDelegate: ((String) -> ())!

    var annotationSceneId = [Int:String]()
    var selectedSceneId: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
    }
}

extension SelectLocationViewController: MGLMapViewDelegate {

}

extension SelectLocationViewController: SelectLocationView {
    func latitude() -> Double {
        return mapView.centerCoordinate.latitude
    }

    func longitude() -> Double {
        return mapView.centerCoordinate.longitude
    }

    func finishWith(latitude: Double, longitude: Double) {
    }
}
