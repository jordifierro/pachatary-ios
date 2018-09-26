import UIKit
import CoreLocation
import RxSwift
import Moya

protocol ExploreExperiencesView {
    func show(experiences: [Experience])
    func showLoader(_ visibility: Bool)
    func showPaginationLoader(_ visibility: Bool)
    func showError(_ visibility: Bool)
    func showRetry(_ visibility: Bool)
    func navigateToExperienceScenes(_ experienceId: String)
    func hasLocationPermission() -> Bool
    func askLocationPermission()
    func askLastKnownLocation()
}

class ExploreExperiencesViewController: UIViewController {
    
    let presenter = ExperienceDependencyInjector.exploreExperiencePresenter
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var lastItemShown = -1
    var cellHeights: [IndexPath : CGFloat] = [:]

    var experiences: [Experience] = []
    var showPaginationLoader = false
    var selectedExperienceId: String!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PACHATARY"

        let nib = UINib.init(nibName: "ExtendedExperienceTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "extendedExperienceCell")
        // Do any additional setup after loading the view, typically from a nib.
        presenter.view = self
        retryButton.addTarget(self, action: #selector(retryClick), for: .touchUpInside)
        self.searchBar.delegate = self
        
        presenter.create()
    }
    
    @objc func retryClick(_ sender: UIButton!) {
        presenter.retryClick()
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
    }
}

extension ExploreExperiencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.showPaginationLoader { return 2 }
        else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return experiences.count }
        else { return 1 }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let loadingCell: PaginatorLoaderViewCell =
                tableView.dequeueReusableCell(withIdentifier: "reuseLoader", for: indexPath)
                    as! PaginatorLoaderViewCell
            loadingCell.bind()
            return loadingCell
        }
        else {
            let cell: ExtendedExperienceTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "extendedExperienceCell", for: indexPath)
                    as! ExtendedExperienceTableViewCell
            cell.bind(experiences[indexPath.row])
            
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
                presenter.lastItemShown()
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
            presenter.experienceClick(experiences[indexPath.row].id)
        }
    }
}

extension ExploreExperiencesViewController: ExploreExperiencesView {

    func show(experiences: [Experience]) {
        self.experiences = experiences
        self.tableView!.reloadData()
    }
    
    func showPaginationLoader(_ visibility: Bool) {
        self.showPaginationLoader = visibility
        self.tableView!.reloadData()
    }

    func showLoader(_ visibility: Bool) {
        if visibility { loaderIndicator.startAnimating() }
        else { loaderIndicator.stopAnimating() }
    }

    func showError(_ visibility: Bool) {
        errorLabel.isHidden = !visibility
    }

    func showRetry(_ visibility: Bool) {
        retryButton.isHidden = !visibility
    }
    
    func navigateToExperienceScenes(_ experienceId: String) {
        selectedExperienceId = experienceId
        performSegue(withIdentifier: "experienceScenesSegue", sender: self)
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
        else { presenter.onPermissionDenied() }
    }
    
    func askLastKnownLocation() {
        let location = locationManager.location
        if location == nil { presenter.onLastLocationNotFound() }
        else { presenter.onLastLocationFound(latitude: location!.coordinate.latitude,
                                             longitude: location!.coordinate.longitude) }
    }
}

extension ExploreExperiencesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchClick(searchBar.text!)
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
                presenter.onPermissionDenied()
                break
            case .authorizedWhenInUse:
                presenter.onPermissionAccepted()
                break
            case .authorizedAlways:
                presenter.onPermissionAccepted()
                break
        }
    }
}
