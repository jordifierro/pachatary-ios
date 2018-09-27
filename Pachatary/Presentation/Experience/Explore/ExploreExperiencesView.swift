import UIKit
import CoreLocation
import RxSwift
import Moya
import TTGSnackbar

protocol ExploreExperiencesView {
    func show(experiences: [Experience])
    func showLoader(_ visibility: Bool)
    func showRetry()
    func navigateToExperienceScenes(_ experienceId: String)
    func hasLocationPermission() -> Bool
    func askLocationPermission()
    func askLastKnownLocation()
}

class ExploreExperiencesViewController: UIViewController {
    
    let presenter = ExperienceDependencyInjector.exploreExperiencePresenter
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var lastItemShown = -1
    var cellHeights: [IndexPath : CGFloat] = [:]

    var experiences: [Experience] = []
    var isLoading = false
    var selectedExperienceId: String!
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
        
        self.title = "PACHATARY"

        let loaderNib = UINib.init(nibName: "LoaderTableViewCell", bundle: nil)
        self.tableView.register(loaderNib, forCellReuseIdentifier: "loaderCell")
        let nib = UINib.init(nibName: "ExtendedExperienceTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "extendedExperienceCell")

        presenter.view = self
        
        self.searchBar.delegate = self
        self.tableView.addSubview(self.refreshControl)
        
        presenter.create()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        presenter.refresh()
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
    }
}

extension ExploreExperiencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading { return experiences.count + 1 }
        return experiences.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func showLoader(_ visibility: Bool) {
        self.isLoading = visibility
        self.tableView!.reloadData()
    }

    func showRetry() {
        let snackbar = TTGSnackbar(message: "Oops! Something went wrong. Please try again",
                                   duration: .forever,
                                   actionText: "RETRY",
                                   actionBlock: { (snackbar) in
                                                    self.presenter.retryClick()
                                                    snackbar.dismiss()
                                                })
        snackbar.show()
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
