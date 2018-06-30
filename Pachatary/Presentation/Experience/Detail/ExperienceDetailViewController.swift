import UIKit
import Mapbox

class ExperienceDetailViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    let presenter = ExperienceDependencyInjector.experienceDetailPresenter
    var experienceId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        presenter.view = self
        presenter.experienceId = experienceId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.create()
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

extension ExperienceDetailViewController: ExperienceDetailView {
    
    func showScenes(_ scenes: [Scene]) {
        if !scenes.isEmpty {
            if mapView.annotations != nil {
                for annotation in mapView.annotations! {
                    mapView.removeAnnotation(annotation)
                }
            }
    
            var maxLatitude = scenes[0].latitude
            var minLatitude = scenes[0].latitude
            var maxLongitude = scenes[0].longitude
            var minLongitude = scenes[0].longitude

            for scene in scenes {
                let point = MGLPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: scene.latitude,
                                                          longitude: scene.longitude)
                point.title = scene.title
                mapView.addAnnotation(point)
                
                maxLatitude = [maxLatitude, scene.latitude].max()!
                minLatitude = [minLatitude, scene.latitude].min()!
                maxLongitude = [maxLongitude, scene.longitude].max()!
                minLongitude = [minLongitude, scene.longitude].min()!
            }

            let latitudeMargin = abs(maxLatitude - minLatitude) / 10
            let longitudeMargin = abs(maxLongitude - minLongitude) / 10
            let bounds = MGLCoordinateBounds(
                sw: CLLocationCoordinate2D(latitude: minLatitude - latitudeMargin,
                                           longitude: minLongitude - longitudeMargin),
                ne: CLLocationCoordinate2D(latitude: maxLatitude + latitudeMargin,
                                           longitude: maxLongitude + longitudeMargin))
            mapView.setVisibleCoordinateBounds(bounds, animated: true)
        }
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }
}
