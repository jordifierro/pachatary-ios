import Swift
import UIKit

protocol SceneListView {
    func showScenes(_ scenes: [Scene], showSceneWithId sceneId: String?)
    func finish()
}

class SceneListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let presenter = SceneDependencyInjector.sceneListPresenter
    var experienceId = "-1"
    var sceneId = "-1"
    var scenes = [Scene]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        presenter.experienceId = experienceId
        presenter.sceneId = sceneId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.create()
    }
}

extension SceneListViewController: SceneListView {

    func showScenes(_ scenes: [Scene], showSceneWithId sceneId: String? = nil) {
        self.scenes = scenes
        self.tableView!.reloadData()
        
        if sceneId != nil {
            let indexPath = IndexPath(row: scenes.index(where: { scene in scene.id == sceneId })!,
                                      section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }
}

extension SceneListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SceneTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "sceneCellIdentifier", for: indexPath)
                as! SceneTableViewCell
        cell.bind(scenes[indexPath.row])
        
        return cell
    }
}
