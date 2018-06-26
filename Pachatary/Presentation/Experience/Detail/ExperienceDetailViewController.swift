import UIKit

class ExperienceDetailViewController: UIViewController {
    
    var experienceId: String!
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLabel.text = experienceId
    }
}

