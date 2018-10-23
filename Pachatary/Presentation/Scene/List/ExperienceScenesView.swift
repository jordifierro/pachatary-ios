import Swift
import UIKit

protocol ExperienceScenesView : class {
    func showScenes(_ scenes: [Scene])
    func showExperience(_ experience: Experience)
    func showExperienceLoading(_ isLoading: Bool)
    func showSceneLoading(_ isLoading: Bool)
    func showRetry()
    func navigateToMap(_ sceneId: String?)
    func navigateToProfile(_ username: String)
    func scrollToScene(_ sceneId: String)
    func showUnsaveConfirmationDialog()
    func showShareDialog(_ url: String)
    func finish()
}

class ExperienceScenesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var presenter: ExperienceScenesPresenter!
    var cellHeights: [IndexPath : CGFloat] = [:]
    var experienceId: String!
    var selectedSceneId: String? = nil
    var selectedProfileUsername: String? = nil
    var scenes = [Scene]()
    var experience: Experience?
    var isLoadingExperience = false
    var isLoadingScenes = false
    var isExperienceDescriptionExpanded = false
    var isSceneDescriptionExpanded = [String:Bool]()

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ExperienceScenesViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = SceneDependencyInjector.sceneListPresenter(view: self,
                                                               experienceId: experienceId)

        let nib = UINib.init(nibName: "ExperienceDetailTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "experienceDetailCell")
        let loaderNib = UINib.init(nibName: "LoaderTableViewCell", bundle: nil)
        self.tableView.register(loaderNib, forCellReuseIdentifier: "loaderCell")
        self.tableView.addSubview(self.refreshControl)

        presenter.create()
    }

    deinit {
        presenter.destroy()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.resume()
    }

    @objc func shareClick(){
        presenter.shareClick()
    }

    @objc func saveExperience(){
        presenter.saveExperience(save: true)
    }

    @objc func unsaveExperience(){
        presenter.saveExperience(save: false)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        presenter.refresh()
        refreshControl.endRefreshing()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "experienceMapSegue" {
            if let destinationVC = segue.destination as? ExperienceMapViewController {
                destinationVC.selectedSceneId = self.selectedSceneId
                destinationVC.experienceId = self.experienceId
                destinationVC.setResultDelegate = { [unowned self] (sceneId: String) in
                    self.presenter.selectedSceneId = sceneId }
            }
        }
        else if segue.identifier == "profileSegue" {
            if let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.username = self.selectedProfileUsername
            }
        }
    }
}

extension ExperienceScenesViewController: ExperienceScenesView {

    func showExperience(_ experience: Experience) {
        configureNavigationItems(experience)
        self.experience = experience
        self.tableView!.reloadData()
    }

    func showScenes(_ scenes: [Scene]) {
        self.scenes = scenes
        self.tableView!.reloadData()
    }

    func showExperienceLoading(_ isLoading: Bool) {
        self.isLoadingExperience = isLoading
        self.tableView!.reloadData()
    }

    func showSceneLoading(_ isLoading: Bool) {
        self.isLoadingScenes = isLoading
        self.tableView!.reloadData()
    }

    func showRetry() {
        Snackbar.showErrorWithRetry({ [weak self] () in self?.presenter.retry() })
    }

    func navigateToMap(_ sceneId: String? = nil) {
        self.selectedSceneId = sceneId
        performSegue(withIdentifier: "experienceMapSegue", sender: self)
    }

    func navigateToProfile(_ username: String) {
        self.selectedProfileUsername = username
        performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    func scrollToScene(_ sceneId: String) {
        let scenePosition = scenes.index(where: { scene in scene.id == sceneId })!
        self.tableView.scrollToRow(at: IndexPath(item: scenePosition, section: 1),
                                   at: .top, animated: true)
    }

    func showUnsaveConfirmationDialog() {
        let dialogMessage = UIAlertController(title: "REMOVE FROM SAVED",
            message: "Are you sure you want to remove it from your saved experiences?",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
                   { [unowned self] (action) -> Void in self.presenter.onUnsaveDialogOk() }
        dialogMessage.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                   { [unowned self] (action) -> Void in self.presenter.onUnsaveDialogCancel() }
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }

    func showShareDialog(_ url: String) {
        let url: URL = URL(string: url)!
        let sharedObjects: [AnyObject] = [url as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    func finish() {
        dismiss(animated: true, completion: nil)
    }

    private func configureNavigationItems(_ experience: Experience) {
        self.navigationItem.rightBarButtonItems = []

        let shareBarButtonItem = UIBarButtonItem(title: "Share", style: .done,
                                                 target: self, action: #selector(shareClick))
        shareBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: .normal)
        shareBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: UIControlState.highlighted)
        self.navigationItem.rightBarButtonItems?.append(shareBarButtonItem)

        var saveBarButtonItem: UIBarButtonItem!
        if experience.isSaved {
            saveBarButtonItem = UIBarButtonItem(title: "Saved", style: .done,
                                                target: self, action: #selector(unsaveExperience))
        }
        else {
            saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done,
                                                target: self, action: #selector(saveExperience))
        }
        saveBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: .normal)
        saveBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: UIControlState.highlighted)
        self.navigationItem.rightBarButtonItems?.append(saveBarButtonItem)
    }
}

extension ExperienceScenesViewController: UITableViewDataSource, UITableViewDelegate {

    enum ViewType {
        case experience
        case scene
        case loader
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoadingScenes { return 1 + scenes.count + 1 }
        else { return 1 + scenes.count }
    }

    private func viewType(_ position: Int) -> ViewType {
        if position == 0 {
            if isLoadingExperience { return .loader }
            else { return .experience }
        }
        else if position == scenes.count + 1 { return .loader }
        else { return .scene }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewType(indexPath.row) {
        case .experience:
            let cell: ExperienceDetailTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "experienceDetailCell", for: indexPath)
                    as! ExperienceDetailTableViewCell
            if experience != nil {
                cell.bind(self.experience!, self.scenes,
                          presenter.onGoToMapClick, presenter.saveExperience, presenter.profileClick,
                          { [unowned self] in
                            self.isExperienceDescriptionExpanded = true
                            self.tableView.reloadData()
                          },
                          isExperienceDescriptionExpanded)
            }
            return cell
        case .scene:
            let cell: SceneTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "sceneCellIdentifier", for: indexPath)
                    as! SceneTableViewCell
            cell.bind(scenes[indexPath.row - 1], presenter.onLocateSceneClick(_:),
                      { [unowned self] (sceneId: String) in
                        self.isSceneDescriptionExpanded[sceneId] = true
                        self.tableView.reloadData()
                      },
                      isSceneDescriptionExpanded[self.scenes[indexPath.row - 1].id] ?? false)
            return cell
        case .loader:
            let loadingCell: LoaderTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "loaderCell", for: indexPath)
                    as! LoaderTableViewCell
            return loadingCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return 70.0 }
        return height
    }
}
