import UIKit
import Mapbox

protocol ExperienceMapView {
    func showScenes(_ scenes: [Scene])
    func selectScene(_ sceneId: String)
    func setResult(_ sceneId: String)
    func finish()
}

class ExperienceMapViewController: UIViewController {
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var mapView: MGLMapView!

    let presenter = ExperienceDependencyInjector.experienceMapPresenter
    var experienceId: String!
    var setResultDelegate: ((String) -> ())!
    
    var annotationSceneId = [Int:String]()
    var selectedSceneId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        presenter.view = self
        presenter.experienceId = experienceId
        presenter.sceneId = selectedSceneId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.create()
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

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "circle")

        if annotationImage == nil {
            let image = UIImage.circle(diameter: 10, color: UIColor.themeGreen)
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "circle")
        }

        return annotationImage
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
    
    func selectScene(_ sceneId: String) {
        for annotation in mapView.annotations! {
            if (annotationSceneId[annotation.hash] == sceneId) {
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    func setResult(_ sceneId: String) {
        self.setResultDelegate(sceneId)
    }
    
    func finish() {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
