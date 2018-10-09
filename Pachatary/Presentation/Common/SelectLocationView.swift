import UIKit
import Mapbox
import TTGSnackbar
import CoreLocation

protocol SelectLocationView : class {
    func latitude() -> Double
    func longitude() -> Double
    func centerMap(_ latitude: Double, _ longitude: Double)
    func geocodeAddress(_ address: String)
    func showAddressNotFound()
    func hasLocationPermission() -> Bool
    func askLocationPermission()
    func askLastKnownLocation()
    func showCannotKnowLocation()
    func finishWith(latitude: Double, longitude: Double)
}

class SelectLocationViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    var presenter: SelectLocationPresenter!
    var initialLatitude: Double?
    var initialLongitude: Double?
    var setResultDelegate: ((Double, Double) -> ())!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = CommonDependencyInjector.selectLocationPresenter(self, initialLatitude,
                                                                     initialLongitude)

        mapView.delegate = self
        self.navigationItem.title = "SELECT LOCATION"
        self.searchBar.delegate = self

        locateButton.addTarget(self,
           action: #selector(SelectLocationViewController.locateButtonClick(_:)),
           for: .touchUpInside)
        doneButton.addTarget(self,
           action: #selector(SelectLocationViewController.doneButtonClick(_:)),
           for: .touchUpInside)

        presenter.create()
    }

    @objc func locateButtonClick(_ sender: UIButton!) {
        presenter.locateClick()
    }

    @objc func doneButtonClick(_ sender: UIButton!) {
        presenter.doneClick()
    }
}

extension SelectLocationViewController: MGLMapViewDelegate {

}

extension SelectLocationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchClick(searchBar.text!)
        searchBar.endEditing(true)
    }
}

extension SelectLocationViewController: SelectLocationView {
    func latitude() -> Double {
        return mapView.centerCoordinate.latitude
    }

    func longitude() -> Double {
        return mapView.centerCoordinate.longitude
    }

    func centerMap(_ latitude: Double, _ longitude: Double) {
        mapView.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoomLevel: 6, animated: true)
    }

    func geocodeAddress(_ address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler:
            { [weak self] (placemarks, error) in
                if error != nil {
                    self?.presenter.onAdressGeocodingError()
                    return
                }
                if placemarks!.count > 0 {
                    let coordinate = placemarks![0].location!.coordinate
                    self?.presenter.onAddressGeocoded(coordinate.latitude, coordinate.longitude)
                }
            })
    }

    func showAddressNotFound() {
        let snackbar = TTGSnackbar(message: "Location not found!", duration: .middle)
        snackbar.show()
    }

    func hasLocationPermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }

    func askLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
        else { presenter.onLocationPermissionDenied() }
    }

    func askLastKnownLocation() {
        let location = locationManager.location
        if location == nil { presenter.onLastLocationNotFound() }
        else { presenter.onLastLocationFound(location!.coordinate.latitude,
                                             location!.coordinate.longitude) }
    }

    func showCannotKnowLocation() {
        let snackbar = TTGSnackbar(message: "Cannot find your location!", duration: .middle)
        snackbar.show()
    }

    func finishWith(latitude: Double, longitude: Double) {
        setResultDelegate(latitude, longitude)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            presenter.onLocationPermissionDenied()
            break
        case .authorizedWhenInUse:
            presenter.onLocationPermissionAccepted()
            break
        case .authorizedAlways:
            presenter.onLocationPermissionAccepted()
            break
        }
    }
}
