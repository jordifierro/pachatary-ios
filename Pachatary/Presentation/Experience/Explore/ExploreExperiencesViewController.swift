import UIKit
import RxSwift
import Moya

class ExploreExperiencesViewController: UIViewController {
    
    let presenter = ExperienceDependencyInjector.exploreExperiencePresenter
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var lastItemShown = -1
    var cellHeights: [IndexPath : CGFloat] = [:]

    var experiences: [Experience] = []
    var showPaginationLoader = false
    var selectedExperienceId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        presenter.view = self
        retryButton.addTarget(self, action: #selector(retryClick), for: .touchUpInside)
        
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
        if segue.identifier == "experienceMapSegue" {
            if let destinationVC = segue.destination as? ExperienceMapViewController {
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
                tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
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
    
    func navigateToExperienceMap(_ experienceId: String) {
        selectedExperienceId = experienceId
        performSegue(withIdentifier: "experienceMapSegue", sender: self)
    }
}
