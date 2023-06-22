//
//  AboutGroupViewController.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit
import ProgressHUD

class AboutGroupViewController: UIViewController {
    
    var channel: Channel!
    var users: [User]!
    var isMember: Bool!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupAbout: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupFollow: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureBackButtonItem()
    }
    
    private func configureBackButtonItem(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.backward.fill"), style: .plain, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureView(){
        imageView.makeRounded()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.layer.borderWidth = CGFloat(2)
        tableView.layer.cornerRadius = 20
        
        tableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "UsersTableViewCell")
        
        for user in users {
            self.isMember = user == User.currentUser
        }
        groupName.text = channel.name
        groupAbout.text = channel.aboutChannel
        
        if channel.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: channel.avatarLink) { image in
                self.imageView.image = image
            }
        }else {
            self.imageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        if channel.adminId == User.currentId {
            groupFollow.setTitle("Delete", for: .normal)
        } else if isMember {
            groupFollow.setTitle("Un Follow", for: .normal)
        } else {
            groupFollow.setTitle("Follow", for: .normal)
        }
        
    }
    
    private func goBack(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    @IBAction func groupFollowClicked(_ sender: Any) {
        if channel.adminId == User.currentId {
            FChannelListener.shared.deleteChannel(channel: channel!) { error in
                guard error == nil else {
                    ProgressHUD.showError(error!)
                    return
                }
                ProgressHUD.showSuccess("Channel Deleted")
                self.goBack()
            }
        } else if isMember {
            if let index = channel.memberIds.firstIndex(of: User.currentId){
                channel.memberIds.remove(at: index)
                FChannelListener.shared.saveChannel(channel)
                goBack()
            }
        } else {
            channel.memberIds.append(User.currentId)
            FChannelListener.shared.saveChannel(channel)
            goBack()
        }
    }

}

extension AboutGroupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell", for: indexPath) as! UsersTableViewCell
        cell.configureCell(user: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.user = users[indexPath.row]
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members"
    }
}
