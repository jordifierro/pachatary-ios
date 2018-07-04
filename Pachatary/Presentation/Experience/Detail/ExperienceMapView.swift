import UIKit
import Mapbox

protocol ExperienceMapView {
    func showScenes(_ scenes: [Scene])
    func navigateToSceneList(with sceneId: String)
    func finish()
}

class ExperienceMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    let presenter = ExperienceDependencyInjector.experienceMapPresenter
    var experienceId: String!
    var annotationSceneId = [Int:String]()
    var selectedSceneId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        presenter.view = self
        presenter.experienceId = experienceId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.create()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sceneListSegue" {
            if let destinationVC = segue.destination as? SceneListViewController {
                destinationVC.sceneId = self.selectedSceneId
                destinationVC.experienceId = self.experienceId
            }
        }
    }
}

extension ExperienceMapViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        presenter.sceneClick(annotationSceneId[annotation.hash]!)
    }
}

extension ExperienceMapViewController: ExperienceMapView {
    
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
                annotationSceneId[point.hash] = scene.id
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
    
    func navigateToSceneList(with sceneId: String) {
        selectedSceneId = sceneId
        performSegue(withIdentifier: "sceneListSegue", sender: self)
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }
}
