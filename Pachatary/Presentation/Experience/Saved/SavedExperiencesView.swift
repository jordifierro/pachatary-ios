import UIKit
import CoreLocation
import RxSwift
import Moya
import TTGSnackbar

protocol SavedExperiencesView : class {
    func show(experiences: [Experience])
    func showLoader(_ visibility: Bool)
    func showRetry()
    func navigateToExperienceScenes(_ experienceId: String)
}

class SavedExperiencesViewController: UIViewController {
    
    var presenter: SavedExperiencesPresenter!
    
    @IBOutlet weak var tableView: UITableView!
    
    var lastItemShown = -1
    var cellHeights: [IndexPath : CGFloat] = [:]

    var experiences: [Experience] = []
    var isLoading = false
    var selectedExperienceId: String!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(SavedExperiencesViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ExperienceDependencyInjector.savedExperiencePresenter(view: self)
        
        self.title = "Saved"
        self.navigationItem.title = "SAVED EXPERIENCES"
        
        let loaderNib = UINib.init(nibName: "LoaderTableViewCell", bundle: nil)
        self.tableView.register(loaderNib, forCellReuseIdentifier: "loaderCell")
        let nib = UINib.init(nibName: "SquareExperienceTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "squareExperienceCell")
        
        self.tableView.addSubview(self.refreshControl)
        
        presenter.create()
    }
    
    deinit {
        self.presenter.destroy()
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

extension SavedExperiencesViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            let cell: SquareExperienceTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "squareExperienceCell", for: indexPath)
                    as! SquareExperienceTableViewCell
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

extension SavedExperiencesViewController: SavedExperiencesView {
    
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
                                   actionBlock: { [weak self] snackbar in
                                    self?.presenter.retryClick()
                                    snackbar.dismiss()
        })
        snackbar.show()
    }
    
    func navigateToExperienceScenes(_ experienceId: String) {
        selectedExperienceId = experienceId
        performSegue(withIdentifier: "experienceScenesSegue", sender: self)
    }
}
