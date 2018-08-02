import Swift
import UIKit

protocol SceneListView {
    func showScenes(_ scenes: [Scene], experience: Experience)
    func navigateToMap()
    func finish()
}

class SceneListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let presenter = SceneDependencyInjector.sceneListPresenter
    var experienceId = "-1"
    var scenes = [Scene]()
    var experience: Experience!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "ExtendedExperienceTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "extendedExperienceCell")
        
        presenter.view = self
        presenter.experienceId = experienceId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.create()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "experienceMapSegue" {
            if let destinationVC = segue.destination as? ExperienceMapViewController {
                destinationVC.experienceId = experienceId
            }
        }
    }
}

extension SceneListViewController: SceneListView {
    
    func showScenes(_ scenes: [Scene], experience: Experience) {
        self.scenes = scenes
        self.experience = experience
        self.tableView!.reloadData()
    }
    
    func navigateToMap() {
        performSegue(withIdentifier: "experienceMapSegue", sender: self)
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }
}

extension SceneListViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            let cell: ExtendedExperienceTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "extendedExperienceCell", for: indexPath)
                    as! ExtendedExperienceTableViewCell
            cell.bind(self.experience, presenter.onGoToMapClick)
            
            return cell
        }
        else {
            let cell: SceneTableViewCell =
                tableView.dequeueReusableCell(withIdentifier: "sceneCellIdentifier", for: indexPath)
                    as! SceneTableViewCell
            cell.bind(scenes[indexPath.row])
    
            return cell
        }
    }
}
