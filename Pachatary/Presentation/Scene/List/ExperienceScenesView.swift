import Swift
import UIKit

protocol ExperienceScenesView : class {
    func showScenes(_ scenes: [Scene], experience: Experience)
    func navigateToMap(_ sceneId: String?)
    func scrollToScene(_ sceneId: String)
    func finish()
}

class ExperienceScenesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var presenter: ExperienceScenesPresenter!
    var cellHeights: [IndexPath : CGFloat] = [:]
    var experienceId: String!
    var selectedSceneId: String? = nil
    var scenes = [Scene]()
    var experience: Experience!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = SceneDependencyInjector.sceneListPresenter(view: self,
                                                               experienceId: experienceId)

        let nib = UINib.init(nibName: "ExperienceDetailTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "experienceDetailCell")
        
        presenter.create()
    }

    deinit {
        presenter.destroy()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.resume()
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
    }
}

extension ExperienceScenesViewController: ExperienceScenesView {
    
    func showScenes(_ scenes: [Scene], experience: Experience) {
        self.scenes = scenes
        self.experience = experience
        self.tableView!.reloadData()
    }
    
    func navigateToMap(_ sceneId: String? = nil) {
        self.selectedSceneId = sceneId
        performSegue(withIdentifier: "experienceMapSegue", sender: self)
    }
    
    func scrollToScene(_ sceneId: String) {
        let scenePosition = scenes.index(where: { scene in scene.id == sceneId })!
        self.tableView.scrollToRow(at: IndexPath(item: scenePosition, section: 1),
                                   at: .top, animated: true)
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }
}

extension ExperienceScenesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.experience != nil { return 1 }
            else { return 0 }
        }
        else { return scenes.count }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: ExperienceDetailTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "experienceDetailCell", for: indexPath)
                    as! ExperienceDetailTableViewCell
            cell.bind(self.experience, self.scenes, presenter.onGoToMapClick, presenter.saveExperience)
            
            return cell
        }
        else {
            let cell: SceneTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "sceneCellIdentifier", for: indexPath)
                    as! SceneTableViewCell
            cell.bind(scenes[indexPath.row], presenter.onLocateSceneClick(_:))
    
            return cell
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
