import UIKit
import CoreLocation
import RxSwift
import Moya

protocol ExploreExperiencesView : class {
    func show(experiences: [Experience])
    func showLoader(_ visibility: Bool)
    func showRetry()
    func navigateToExperienceScenes(_ experienceId: String)
    func navigateToProfile(_ username: String)
    func navigateToSelectLocation(_ latitude: Double?, _ longitude: Double?)
    func hasLocationPermission() -> Bool
    func askLocationPermission()
    func askLastKnownLocation()
}

class ExploreExperiencesViewController: UIViewController {
    
    var presenter: ExploreExperiencesPresenter?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectLocationButton: UIButton!
    
    var lastItemShown = -1
    var cellHeights: [IndexPath : CGFloat] = [:]

    var experiences: [Experience] = []
    var isLoading = false
    var selectedExperienceId: String?
    var selectedProfileUsername: String?
    var selectLocationLatitude: Double? = nil
    var selectLocationLongitude: Double? = nil
    let locationManager = CLLocationManager()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ExploreExperiencesViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ExperienceDependencyInjector.exploreExperiencePresenter(view: self)

        self.navigationItem.title = "PACHATARY"
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.font: UIFont(name: "Bahiana-Regular", size: 40)!]

        let loaderNib = UINib.init(nibName: "LoaderTableViewCell", bundle: nil)
        self.tableView.register(loaderNib, forCellReuseIdentifier: "loaderCell")
        let nib = UINib.init(nibName: "ExtendedExperienceTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "extendedExperienceCell")

        self.searchBar.delegate = self
        self.tableView.addSubview(self.refreshControl)
        selectLocationButton.addTarget(self,
               action: #selector(ExploreExperiencesViewController.selectLocactionButtonClick(_:)),
               for: .touchUpInside)

        presenter!.create()
    }

    @objc func selectLocactionButtonClick(_ sender: UIButton!) {
        presenter!.onSelectLocationClick()
    }

    deinit {
        self.presenter?.destroy()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        presenter!.refresh()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "experienceScenesSegue" {
            if let destinationVC = segue.destination as? ExperienceScenesViewController {
                destinationVC.experienceId = selectedExperienceId
            }
        }
        else if segue.identifier == "profileSegue" {
            if let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.username = selectedProfileUsername
            }
        }
        else if segue.identifier == "selectLocationSegue" {
            if let destinationVC = segue.destination as? SelectLocationViewController {
                destinationVC.initialLatitude = selectLocationLatitude
                destinationVC.initialLongitude = selectLocationLongitude
                destinationVC.setResultDelegate =
                    { [unowned self] (latitude: Double, longitude: Double) in
                        self.presenter!.onLastLocationFound(latitude: latitude, longitude: longitude)
                    }
            }
        }
    }
}

extension ExploreExperiencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading { return experiences.count + 1 }
        if experiences.count > 0 { return experiences.count }
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && experiences.count == 0 && !isLoading {
            return tableView.dequeueReusableCell(withIdentifier: "noResultsFoundCell", for: indexPath)
        }
        if indexPath.row == experiences.count {
            let loadingCell: LoaderTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "loaderCell", for: indexPath)
                    as! LoaderTableViewCell
            return loadingCell
        }
        else {
            let cell: ExtendedExperienceTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "extendedExperienceCell", for: indexPath)
                    as! ExtendedExperienceTableViewCell
            cell.bind(experiences[indexPath.row],
                      { [unowned self] username in self.presenter!.profileClick(username) })
            return cell
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRowsIndexPaths = self.tableView.indexPathsForVisibleRows
        if visibleRowsIndexPaths != nil && visibleRowsIndexPaths!.count > 0 {
            var visibleRows = [Int]()
            for indexPath in visibleRowsIndexPaths! {
                visibleRows.append(indexPath.row)
            }
            let maxRow = visibleRows.max()!
            if (maxRow == self.experiences.count - 1) && (maxRow > lastItemShown) {
                presenter!.lastItemShown()
            }
            lastItemShown = maxRow
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return 70.0 }
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= experiences.count {
            presenter!.experienceClick(experiences[indexPath.row].id)
        }
    }
}

extension ExploreExperiencesViewController: ExploreExperiencesView {

    func show(experiences: [Experience]) {
        self.experiences = experiences
        self.tableView!.reloadData()
    }
    
    func showLoader(_ visibility: Bool) {
        self.isLoading = visibility
        self.tableView!.reloadData()
    }

    func showRetry() {
        Snackbar.showErrorWithRetry({ [weak self] () in self?.presenter!.retryClick() })
    }
    
    func navigateToExperienceScenes(_ experienceId: String) {
        selectedExperienceId = experienceId
        performSegue(withIdentifier: "experienceScenesSegue", sender: self)
    }
    
    func navigateToProfile(_ username: String) {
        selectedProfileUsername = username
        performSegue(withIdentifier: "profileSegue", sender: self)
    }

    func navigateToSelectLocation(_ latitude: Double?, _ longitude: Double?) {
        selectLocationLatitude = latitude
        selectLocationLongitude = longitude
        performSegue(withIdentifier: "selectLocationSegue", sender: self)
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
        else { presenter!.onPermissionDenied() }
    }
    
    func askLastKnownLocation() {
        let location = locationManager.location
        if location == nil { presenter!.onLastLocationNotFound() }
        else { presenter!.onLastLocationFound(latitude: location!.coordinate.latitude,
                                             longitude: location!.coordinate.longitude) }
    }
}

extension ExploreExperiencesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter!.searchClick(searchBar.text!)
        searchBar.endEditing(true)
    }
}

extension ExploreExperiencesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted, .denied:
                presenter!.onPermissionDenied()
                break
            case .authorizedWhenInUse:
                presenter!.onPermissionAccepted()
                break
            case .authorizedAlways:
                presenter!.onPermissionAccepted()
                break
        }
    }
}
