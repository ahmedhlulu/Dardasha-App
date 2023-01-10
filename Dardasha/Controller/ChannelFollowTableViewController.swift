//
//  ChannelFollowTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 10/01/2023.
//

import UIKit

protocol ChannelFollowTableViewControllerDelegate {
    func didClickFollow()
}

class ChannelFollowTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var membersLbl: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    var channel: Channel?
    var followDelegate: ChannelFollowTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.makeRounded()
        configureChannel()
        configureRightBarButton()
    }

    // MARK: - configure Channel view
    private func configureChannel(){
        guard channel != nil else {return}
        
        self.nameLbl.text = channel!.name
        self.membersLbl.text = "\(channel!.memberIds.count) members"
        self.aboutTextView.text = channel!.aboutChannel
        self.title = channel!.name
        
        if channel!.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: channel!.avatarLink) { image in
                DispatchQueue.main.async {
                    self.avatarImageView.image = image != nil ? image : UIImage(systemName: "person.circle.fill")
                }
            }
        }else{
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    // MARK: - configure Channel view
    private func configureRightBarButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(rightBarButtonClicked))
    }
    
    @objc func rightBarButtonClicked(){
        channel!.memberIds.append(User.currentId)
        FChannelListener.shared.saveChannel(channel!)
        followDelegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }
    
}
