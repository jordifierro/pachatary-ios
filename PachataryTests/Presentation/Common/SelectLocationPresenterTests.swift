import Swift
import XCTest
@testable import Pachatary

class SelectLocationPresenterTests: XCTestCase {

    func test_on_create_presenter_with_latitude_and_longitude_centers_map() {
        ScenarioMaker()
            .given_a_presenter(1.2, -3.4)
            .when_create()
            .then_should_center_map(1.2, -3.4)
    }

    func test_on_search_click_calls_geocode_address() {
        ScenarioMaker()
            .given_a_presenter()
            .when_search_click("place")
            .then_should_geocode_address("place")
    }

    func test_on_address_geocoded_centers_map() {
        ScenarioMaker()
            .given_a_presenter()
            .when_address_geocoded(5.6, -7.8)
            .then_should_center_map(5.6, -7.8)
    }

    func test_on_address_geocoding_error_shows_address_not_found() {
        ScenarioMaker()
            .given_a_presenter()
            .when_address_geocoding_error()
            .then_should_show_address_not_found()
    }

    func test_on_done_click_gets_latitude_and_longitude_and_finishes_with_them() {
        ScenarioMaker()
            .given_a_presenter()
            .given_a_latitude_and_longitude(9.0, -3.2)
            .when_done()
            .then_should_finish_with(9.0, -3.2)
    }

    func test_on_locate_click_asks_location_if_has_perms() {
        ScenarioMaker()
            .given_a_presenter()
            .given_location_permission(true)
            .when_locate_click()
            .then_should_ask_location()
    }

    func test_on_locate_click_asks_perms_if_has_no_perms() {
        ScenarioMaker()
            .given_a_presenter()
            .given_location_permission(false)
            .when_locate_click()
            .then_should_ask_permission()
    }

    func test_on_perms_accepted_asks_location() {
        ScenarioMaker()
            .given_a_presenter()
            .when_permission_accepted()
            .then_should_ask_location()
    }

    func test_on_perms_denied_shows_location_not_found() {
        ScenarioMaker()
            .given_a_presenter()
            .when_permission_denied()
            .then_should_show_location_not_found()
    }

    func test_on_location_found_centers_map() {
        ScenarioMaker()
            .given_a_presenter()
            .when_location_found(5.4, 7.2)
            .then_should_center_map(5.4, 7.2)
    }

    func test_on_location_not_found_shows_not_found() {
        ScenarioMaker()
            .given_a_presenter()
            .when_location_not_found()
            .then_should_show_location_not_found()
    }

    class ScenarioMaker {

        var presenter: SelectLocationPresenter!
        let mockView = SelectLocationViewMock()

        init() {}

        func given_a_presenter(_ latitude: Double? = nil, _ longitude: Double? = nil) -> ScenarioMaker {
            presenter = SelectLocationPresenter(mockView, latitude, longitude)
            return self
        }

        func given_a_latitude_and_longitude(_ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            mockView.latitudeResult = latitude
            mockView.longitudeResult = longitude
            return self
        }

        func given_location_permission(_ hasPerms: Bool) -> ScenarioMaker {
            mockView.hasLocationPermissionResult = hasPerms
            return self
        }

        func when_create() -> ScenarioMaker {
            presenter.create()
            return self
        }

        func when_search_click(_ address: String) -> ScenarioMaker {
            presenter.searchClick(address)
            return self
        }

        func when_address_geocoded(_ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            presenter.onAddressGeocoded(latitude, longitude)
            return self
        }

        func when_address_geocoding_error() -> ScenarioMaker {
            presenter.onAdressGeocodingError()
            return self
        }

        func when_done() -> ScenarioMaker {
            presenter.doneClick()
            return self
        }

        func when_locate_click() -> ScenarioMaker {
            presenter.locateClick()
            return self
        }

        func when_permission_accepted() -> ScenarioMaker {
            presenter.onLocationPermissionAccepted()
            return self
        }

        func when_permission_denied() -> ScenarioMaker {
            presenter.onLocationPermissionDenied()
            return self
        }

        func when_location_found(_ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            presenter.onLastLocationFound(latitude, longitude)
            return self
        }

        func when_location_not_found() -> ScenarioMaker {
            presenter.onLastLocationNotFound()
            return self
        }

        @discardableResult
        func then_should_center_map(_ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            assert(mockView.centerMapCalls.count == 1)
            assert(mockView.centerMapCalls[0].0 == latitude)
            assert(mockView.centerMapCalls[0].1 == longitude)
            return self
        }

        @discardableResult
        func then_should_geocode_address(_ address: String) -> ScenarioMaker {
            assert(mockView.geocodeAddressCalls.count == 1)
            assert(mockView.geocodeAddressCalls[0] == address)
            return self
        }

        @discardableResult
        func then_should_show_address_not_found() -> ScenarioMaker {
            assert(mockView.showAddressNotFoundCalls == 1)
            return self
        }

        @discardableResult
        func then_should_finish_with(_ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            assert(mockView.finishViewWithCalls.count == 1)
            assert(mockView.finishViewWithCalls[0].0 == latitude)
            assert(mockView.finishViewWithCalls[0].1 == longitude)
            return self
        }

        @discardableResult
        func then_should_ask_location() -> ScenarioMaker {
            assert(mockView.askLastKnownLocationCalls == 1)
            return self
        }

        @discardableResult
        func then_should_ask_permission() -> ScenarioMaker {
            assert(mockView.askLocationPermissionCalls == 1)
            return self
        }

        @discardableResult
        func then_should_show_location_not_found() -> ScenarioMaker {
            assert(mockView.showCannotKnowLocationCalls == 1)
            return self
        }
    }
}

class SelectLocationViewMock: SelectLocationView {

    var latitudeResult: Double!
    var longitudeResult: Double!
    var centerMapCalls = [(Double, Double)]()
    var geocodeAddressCalls = [String]()
    var showAddressNotFoundCalls = 0
    var hasLocationPermissionResult: Bool!
    var askLocationPermissionCalls = 0
    var askLastKnownLocationCalls = 0
    var showCannotKnowLocationCalls = 0
    var finishViewWithCalls = [(Double, Double)]()

    func latitude() -> Double {
        return latitudeResult
    }

    func longitude() -> Double {
        return longitudeResult
    }

    func centerMap(_ latitude: Double, _ longitude: Double) {
        centerMapCalls.append((latitude, longitude))
    }

    func geocodeAddress(_ address: String) {
        geocodeAddressCalls.append(address)
    }

    func showAddressNotFound() {
        showAddressNotFoundCalls += 1
    }

    func hasLocationPermission() -> Bool {
        return hasLocationPermissionResult
    }

    func askLocationPermission() {
        askLocationPermissionCalls += 1
    }

    func askLastKnownLocation() {
        askLastKnownLocationCalls += 1
    }

    func showCannotKnowLocation() {
        showCannotKnowLocationCalls += 1
    }

    func finishWith(latitude: Double, longitude: Double) {
        finishViewWithCalls.append((latitude, longitude))
    }
}
