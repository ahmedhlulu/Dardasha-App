//
//  SettingTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var appVersionLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.makeRounded()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }

    @IBAction func tellaFriendClicked(_ sender: Any) {
    }
    @IBAction func TermsClicked(_ sender: Any) {
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        FUserListener.shared.logoutCurrentUser { error in
            if error == nil {
                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
                loginView.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    self.present(loginView, animated: true)
                }
            }
        }
    }
    
    // MARK: - Update UI
    private func showUserInfo() {
        if let user = User.currentUser {
            usernameLbl.text = user.username
            statusLbl.text = user.status
            appVersionLbl.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            if user.avatarLink != "" {
                // TODO: download avatar
                FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                    self.avatarImageView.image = image
                }
            }
        }
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "ColorTableView")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "EditProfileSegue", sender: self)
        }
    }
    
}
