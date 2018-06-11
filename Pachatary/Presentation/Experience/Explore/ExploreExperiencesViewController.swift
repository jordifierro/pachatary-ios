import UIKit
import RxSwift
import Moya

class ExploreExperiencesViewController: UIViewController {
    
    let presenter = ExperienceDependencyInjector.exploreExperiencePresenter
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var experiences: [Experience] = []

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
}
