import Swift

class SelectLocationPresenter {

    unowned let view: SelectLocationView
    let initialLatitude: Double?
    let initialLongitude: Double?

    init(_ view: SelectLocationView,
         _ latitude: Double?, _ longitude: Double?) {
        self.view = view
        self.initialLatitude = latitude
        self.initialLongitude = longitude
    }

    func create() {
        if initialLatitude != nil && initialLongitude != nil {
            view.centerMap(initialLatitude!, initialLongitude!)
        }
    }

    func searchClick(_ text: String) {
        view.geocodeAddress(text)
    }

    func onAddressGeocoded(_ latitude: Double, _ longitude: Double) {
        view.centerMap(latitude, longitude)
    }

    func onAdressGeocodingError() {
        view.showAddressNotFound()
    }

    func doneClick() {
        view.finishWith(latitude: view.latitude(), longitude: view.longitude())
    }

    func locateClick() {
        if view.hasLocationPermission() { view.askLastKnownLocation() }
        else { view.askLocationPermission() }
    }

    func onLocationPermissionAccepted() {
        view.askLastKnownLocation()
    }

    func onLocationPermissionDenied() {
        view.showCannotKnowLocation()
    }

    func onLastLocationFound(_ latitude: Double, _ longitude: Double) {
        view.centerMap(latitude, longitude)
    }

    func onLastLocationNotFound() {
        view.showCannotKnowLocation()
    }
}
