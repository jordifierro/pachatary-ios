import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var segueWebViewType: WebViewController.WebViewType?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "SETTINGS"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            let destinationVC = segue.destination as? WebViewController
            destinationVC?.webViewType = segueWebViewType!
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell: SettingsTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
                as! SettingsTableViewCell
        if indexPath.row == 0 { settingsCell.titleLabel.text = "Terms and conditions" }
        else if indexPath.row == 1 { settingsCell.titleLabel.text = "Privacy policy" }
        return settingsCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            segueWebViewType = WebViewController.WebViewType.termsAndConditions
        }
        else if indexPath.row == 1 {
            segueWebViewType = WebViewController.WebViewType.privacyPolicy
        }
        performSegue(withIdentifier: "webViewSegue", sender: self)
    }
}
