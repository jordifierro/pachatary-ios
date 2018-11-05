import UIKit
import CoreLocation
import RxSwift
import Moya

protocol SavedExperiencesView : class {
    func show(experiences: [Experience])
    func showLoader(_ visibility: Bool)
    func showRetry()
    func navigateToExperienceScenes(_ experienceId: String)
}

class SavedExperiencesViewController: UIViewController {
    
    var presenter: SavedExperiencesPresenter?
    
    @IBOutlet weak var collectionView: UICollectionView!

    var lastItemShown = -1

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
        
        self.navigationItem.title = "SAVED EXPERIENCES"
        
        let loaderNib = UINib.init(nibName: "LoaderCollectionViewCell", bundle: nil)
        self.collectionView.register(loaderNib, forCellWithReuseIdentifier: "loaderCollectionCell")
        let nib = UINib.init(nibName: "SquareExperienceCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "squareExperienceCell")
        
        self.collectionView.addSubview(self.refreshControl)
        
        presenter!.create()
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
    }
}

extension SavedExperiencesViewController: UICollectionViewDataSource, UICollectionViewDelegate,
                                                                UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading { return experiences.count + 1 }
        if experiences.count > 0 { return experiences.count }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == experiences.count && !isLoading {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "noContentCell", for: indexPath)
        }
        if indexPath.row == experiences.count {
            let loadingCell: LoaderCollectionViewCell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "loaderCollectionCell", for: indexPath)
                    as! LoaderCollectionViewCell
            loadingCell.setNeedsUpdateConstraints()
            loadingCell.updateConstraintsIfNeeded()
            loadingCell.layoutIfNeeded()
            return loadingCell
        }
        else {
            let cell: SquareExperienceCollectionViewCell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "squareExperienceCell", for: indexPath)
                    as! SquareExperienceCollectionViewCell
            cell.bind(experiences[indexPath.row])
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width

        if indexPath.row == experiences.count {
            return CGSize(width: availableWidth - 10, height: availableWidth - 10)
        }
        else { return CGSize(width: availableWidth / 2 - 5, height: availableWidth / 2 - 5) }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let visibleRowsIndexPaths = self.collectionView.indexPathsForVisibleItems
        if visibleRowsIndexPaths.count > 0 {
            var visibleRows = [Int]()
            for indexPath in visibleRowsIndexPaths {
                visibleRows.append(indexPath.row)
            }
            let maxRow = visibleRows.max()!
            if (maxRow == self.experiences.count - 1) && (maxRow > lastItemShown) {
                presenter!.lastItemShown()
            }
            lastItemShown = maxRow
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row <= experiences.count {
            presenter!.experienceClick(experiences[indexPath.row].id)
        }
    }
}

extension SavedExperiencesViewController: SavedExperiencesView {
    
    func show(experiences: [Experience]) {
        self.experiences = experiences
        self.collectionView!.reloadData()
    }
    
    func showLoader(_ visibility: Bool) {
        self.isLoading = visibility
        self.collectionView!.reloadData()
    }
    
    func showRetry() {
        Snackbar.showErrorWithRetry({ [weak self] () in self?.presenter!.retryClick() })
    }
    
    func navigateToExperienceScenes(_ experienceId: String) {
        selectedExperienceId = experienceId
        performSegue(withIdentifier: "experienceScenesSegue", sender: self)
    }
}
