import UIKit
import CoreLocation
import RxSwift
import Moya

protocol MyExperiencesView : class {
    func showExperiences(_ experiences: [Experience])
    func showLoadingExperiences(_ visibility: Bool)
    func showProfile(_ profile: Profile)
    func showLoadingProfile(_ visibility: Bool)
    func showRetry()
    func navigateToExperienceScenes(_ experienceId: String)
    func showShareDialog(_ username: String)
}

class MyExperiencesViewController: UIViewController {

    var presenter: MyExperiencesPresenter?

    @IBOutlet weak var collectionView: UICollectionView!
    
    var lastItemShown = -1

    var experiences: [Experience] = []
    var isLoadingExperiences = false
    var profile: Profile? = nil
    var isLoadingProfile = false
    var selectedExperienceId: String!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(MyExperiencesViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ExperienceDependencyInjector.myExperiencesPresenter(view: self)

        let loaderNib = UINib.init(nibName: "LoaderCollectionViewCell", bundle: nil)
        self.collectionView.register(loaderNib, forCellWithReuseIdentifier: "loaderCollectionCell")
        let nib = UINib.init(nibName: "SquareExperienceCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "squareExperienceCell")
        let profileNib = UINib.init(nibName: "ProfileCollectionViewCell", bundle: nil)
        self.collectionView.register(profileNib, forCellWithReuseIdentifier: "profileCell")

        self.collectionView.addSubview(self.refreshControl)

        let shareBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "icShare.png")?.withRenderingMode(.alwaysTemplate),
            style: .done, target: self, action: #selector(shareClick))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem

        presenter!.create()
    }

    deinit {
        self.presenter?.destroy()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        presenter!.refresh()
        refreshControl.endRefreshing()
    }

    @objc func shareClick(){
        presenter!.shareClick()
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

extension MyExperiencesViewController: UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {

    enum ViewType {
        case loader
        case experience
        case profile
    }

    func viewType(_ index: Int) -> ViewType {
        if index == 0 {
            if isLoadingProfile { return .loader }
            else { return .profile }
        }
        else if index == 1 {
            if isLoadingExperiences { return .loader }
            else { return .experience }
        }
        else if index == experiences.count + 1 { return .loader }
        return .experience
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoadingExperiences && isLoadingProfile { return 1 }
        else if isLoadingProfile { return experiences.count + 1 }
        else if isLoadingExperiences { return experiences.count + 2 }
        else { return experiences.count + 1 }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewType(indexPath.row) {
        case .loader:
            let loadingCell: LoaderCollectionViewCell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "loaderCollectionCell", for: indexPath)
                    as! LoaderCollectionViewCell
            loadingCell.setNeedsUpdateConstraints()
            loadingCell.updateConstraintsIfNeeded()
            loadingCell.layoutIfNeeded()
            return loadingCell
        case .experience:
            let cell: SquareExperienceCollectionViewCell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "squareExperienceCell", for: indexPath)
                    as! SquareExperienceCollectionViewCell
            cell.bind(experiences[indexPath.row - 1])
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.layoutIfNeeded()
            return cell
        case .profile:
            let cell: ProfileCollectionViewCell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath)
                    as! ProfileCollectionViewCell
            if profile != nil { cell.bind(profile!) }
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.layoutIfNeeded()
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = self.collectionView.frame.width

        switch viewType(indexPath.row) {
        case .loader:
            return CGSize(width: availableWidth, height: availableWidth)
        case .profile:
            return CGSize(width: availableWidth, height: 310)
        case .experience:
            return CGSize(width: availableWidth / 2, height: availableWidth / 2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
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
        if indexPath.row <= experiences.count && indexPath.row > 0 {
            presenter!.experienceClick(experiences[indexPath.row - 1].id)
        }
    }
}

extension MyExperiencesViewController: MyExperiencesView {
    func showExperiences(_ experiences: [Experience]) {
        self.experiences = experiences
        self.collectionView!.reloadData()
    }

    func showLoadingExperiences(_ visibility: Bool) {
        self.isLoadingExperiences = visibility
        self.collectionView!.reloadData()
    }

    func showProfile(_ profile: Profile) {
        self.profile = profile
        self.collectionView!.reloadData()
    }

    func showLoadingProfile(_ visibility: Bool) {
        self.isLoadingProfile = visibility
        self.collectionView!.reloadData()
    }

    func showRetry() {
        Snackbar.showErrorWithRetry({ [weak self] () in self?.presenter!.retryClick() })
    }

    func navigateToExperienceScenes(_ experienceId: String) {
        selectedExperienceId = experienceId
        performSegue(withIdentifier: "experienceScenesSegue", sender: self)
    }

    func showShareDialog(_ username: String) {
        if profile != nil {
            let url: URL = URL(string: AppDataDependencyInjector.publicUrl + "/p/" + username)!
            let sharedObjects: [AnyObject] = [url as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}
