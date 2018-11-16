import Swift
import UIKit

protocol ExperienceScenesView : class {
    func showScenes(_ scenes: [Scene])
    func showExperience(_ experience: Experience, _ isExperienceEditableIfMine: Bool)
    func showExperienceLoading(_ isLoading: Bool)
    func showSceneLoading(_ isLoading: Bool)
    func showRetry()
    func showFlagSuccess()
    func showFlagError()
    func navigateToMap(_ sceneId: String?)
    func navigateToProfile(_ username: String)
    func navigateToEditExperience()
    func navigateToEditScene(_ sceneId: String)
    func navigateToAddScene()
    func scrollToScene(_ sceneId: String)
    func showUnsaveConfirmationDialog()
    func showShareDialog(_ url: String)
    func showFlagOptionsDialog()
    func finish()
}

class ExperienceScenesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var presenter: ExperienceScenesPresenter!
    var experienceId: String!
    var canNavigateToProfile = true
    var isExperienceEditableIfMine = false

    var selectedSceneId: String? = nil
    var selectedProfileUsername: String? = nil
    var scenes = [Scene]()
    var experience: Experience?
    var isLoadingExperience = false
    var isLoadingScenes = false
    var isExperienceDescriptionExpanded = false
    var isSceneDescriptionExpanded = [String:Bool]()
    var sceneIdSelectedToEdit: String?
    var cellHeights: [IndexPath : CGFloat] = [:]

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ExperienceScenesViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = SceneDependencyInjector.experienceScenesPresenter(
            view: self, experienceId: experienceId, canNavigateToProfile: canNavigateToProfile,
            isExperienceEditableIfMine: isExperienceEditableIfMine)

        let nib = UINib.init(nibName: "ExperienceDetailTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "experienceDetailCell")
        let loaderNib = UINib.init(nibName: "LoaderTableViewCell", bundle: nil)
        self.tableView.register(loaderNib, forCellReuseIdentifier: "loaderCell")
        self.tableView.addSubview(self.refreshControl)

        presenter.create()
    }

    override func viewDidAppear(_ animated: Bool) {
        presenter.resume()
    }

    @objc func shareClick(){
        presenter.shareClick()
    }

    @objc func flagClick(){
        presenter.flagClick()
    }

    @objc func editClick(){
        presenter.editClick()
    }

    @objc func addClick(){
        presenter.addClick()
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
        else if segue.identifier == "editExperienceSegue" {
            let destinationVC = segue.destination as! EditExperienceViewController
            destinationVC.experienceId = self.experienceId
        }
        else if segue.identifier == "createSceneSegue" {
            let destinationVC = segue.destination as! CreateSceneViewController
            destinationVC.experienceId = self.experienceId
        }
        else if segue.identifier == "editSceneSegue" {
            let destinationVC = segue.destination as! EditSceneViewController
            destinationVC.experienceId = self.experienceId
            destinationVC.sceneId = self.sceneIdSelectedToEdit!
        }
    }
}

extension ExperienceScenesViewController: ExperienceScenesView {

    func showExperience(_ experience: Experience, _ isExperienceEditableIfMine: Bool) {
        configureNavigationItems(experience, isExperienceEditableIfMine)
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

    func showFlagSuccess() {
        Snackbar.show(
            "Experience successfully reported! We will review it as soon as possible...".localized(),
            .long)
    }
    func showFlagError() {
        Snackbar.showError()
    }

    func navigateToMap(_ sceneId: String? = nil) {
        self.selectedSceneId = sceneId
        performSegue(withIdentifier: "experienceMapSegue", sender: self)
    }

    func navigateToProfile(_ username: String) {
        self.selectedProfileUsername = username
        performSegue(withIdentifier: "profileSegue", sender: self)
    }

    func navigateToEditExperience() {
        performSegue(withIdentifier: "editExperienceSegue", sender: self)
    }

    func navigateToAddScene() {
        performSegue(withIdentifier: "createSceneSegue", sender: self)
    }

    func navigateToEditScene(_ sceneId: String) {
        sceneIdSelectedToEdit = sceneId
        performSegue(withIdentifier: "editSceneSegue", sender: self)
    }

    func scrollToScene(_ sceneId: String) {
        let scenePosition = scenes.index(where: { scene in scene.id == sceneId })!
        self.tableView.scrollToRow(at: IndexPath(item: scenePosition + 1, section: 0),
                                   at: .top, animated: true)
    }

    func showUnsaveConfirmationDialog() {
        let dialogMessage = UIAlertController(title: "REMOVE FROM SAVED".localized(),
            message: "Are you sure you want to remove it from your saved experiences?".localized(),
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK".localized(), style: .default)
                   { [unowned self] (action) -> Void in self.presenter.onUnsaveDialogOk() }
        dialogMessage.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
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
        self.navigationController?.popViewController(animated: true)
    }

    func showFlagOptionsDialog() {
        let optionsDialog = UIAlertController(title: "REPORT EXPERIENCE".localized(),
            message: "Why do you want to report this experience?".localized(),
            preferredStyle: .actionSheet)
        optionsDialog.addAction(UIAlertAction(title: "I don't like it".localized(), style: .default)
            { [unowned self] (action) in self.presenter.flagReasonChosen("I don't like it") })
        optionsDialog.addAction(UIAlertAction(title: "Spam".localized(), style: .default)
        { [unowned self] (action) in self.presenter.flagReasonChosen("Spam") })
        optionsDialog.addAction(UIAlertAction(title: "False or misleading".localized(), style: .default)
        { [unowned self] (action) in self.presenter.flagReasonChosen("False or misleading") })
        optionsDialog.addAction(UIAlertAction(title: "Offensive".localized(), style: .default)
        { [unowned self] (action) in self.presenter.flagReasonChosen("Offensive") })
        optionsDialog.addAction(UIAlertAction(title: "Sexually inappropiate".localized(), style: .default)
        { [unowned self] (action) in self.presenter.flagReasonChosen("Sexually inappropiate") })
        optionsDialog.addAction(UIAlertAction(title: "Violent or prohibited".localized(), style: .default)
        { [unowned self] (action) in self.presenter.flagReasonChosen("Violent or prohibited") })
        optionsDialog.addAction(UIAlertAction(title: "Copyright infringement".localized(), style: .default)
        { [unowned self] (action) in self.presenter.flagReasonChosen("Copyright infringement") })
        optionsDialog.addAction(UIAlertAction(title: "Other reason".localized(), style: .default)
        { [unowned self] (action) in self.presenter.flagReasonChosen("Other reason") })
        optionsDialog.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        if let popoverController = optionsDialog.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(optionsDialog, animated: true, completion: nil)
    }

    private func configureNavigationItems(_ experience: Experience,
                                          _ isExperienceEditableIfMine: Bool) {
        self.navigationItem.rightBarButtonItems = []

        let shareBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "icShare.png")?.withRenderingMode(.alwaysTemplate),
            style: .done, target: self, action: #selector(shareClick))
        self.navigationItem.rightBarButtonItems?.append(shareBarButtonItem)

        if !experience.isMine {
            var saveBarButtonItem: UIBarButtonItem!
            if experience.isSaved {
                let starActiveIcon = UIImage(named: "icStarActive.png")?.withRenderingMode(.alwaysOriginal)
                saveBarButtonItem = UIBarButtonItem(image: starActiveIcon,
                    style: .done, target: self, action: #selector(unsaveExperience))
            }
            else {
                let starIcon = UIImage(named: "icStar.png")?.withRenderingMode(.alwaysOriginal)
                saveBarButtonItem = UIBarButtonItem(image: starIcon,
                    style: .done, target: self, action: #selector(saveExperience))
            }
            saveBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: .normal)
            saveBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: UIControlState.highlighted)
            self.navigationItem.rightBarButtonItems?.append(saveBarButtonItem)

            let flagBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "icFlag.png")?.withRenderingMode(.alwaysTemplate),
                style: .done, target: self, action: #selector(flagClick))
            self.navigationItem.rightBarButtonItems?.append(flagBarButtonItem)
        }
        else if experience.isMine && isExperienceEditableIfMine {
            let editBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "icEdit.png")?.withRenderingMode(.alwaysTemplate),
                style: .done, target: self, action: #selector(editClick))
            self.navigationItem.rightBarButtonItems?.append(editBarButtonItem)

            let addBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "icAddCircle.png")?.withRenderingMode(.alwaysOriginal),
                style: .done, target: self, action: #selector(addClick))
            self.navigationItem.rightBarButtonItems?.append(addBarButtonItem)
        }
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
                      { [unowned self] (sceneId: String) in
                        self.presenter.editSceneClick(sceneId)
                      },
                      (self.experience != nil ?
                        self.experience!.isMine && isExperienceEditableIfMine : false),
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
