//
//  ProfileTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 12/09/2022.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        avatarImageView.makeRounded()
        setupUI()
    }
    
    private func setupUI(){
        if user != nil {
            self.title = user!.username
            usernameLbl.text = user!.username
            statusLbl.text = user!.status
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { image in
                    self.avatarImageView.image = image
                }
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "ColorTableView")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            print("start chating")
            
            let chatId = startChat(sender: User.currentUser!, receiver: user!)
            let privateMSGView = MSGViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.username)
            
            navigationController?.pushViewController(privateMSGView, animated: true)
        }
    }

}
