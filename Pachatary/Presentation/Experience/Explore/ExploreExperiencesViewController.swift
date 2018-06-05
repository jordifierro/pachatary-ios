import UIKit
import RxSwift
import Moya

class ExploreExperiencesViewController: UIViewController {
    
    let presenter = ExperienceDependencyInjector.exploreExperiencePresenter
    
    @IBOutlet weak var tableView: UITableView!
    var experiences: [Experience] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        presenter.view = self
        presenter.create()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ExploreExperiencesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experiences.count
    }
    
    func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExtendedExperienceTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                as! ExtendedExperienceTableViewCell
        cell.bind(experiences[indexPath.row])
        return cell
    }
}

extension ExploreExperiencesViewController: ExploreExperiencesView {
    
    func show(experiences: [Experience]) {
        self.experiences = experiences
        self.tableView!.reloadData()
    }
}
