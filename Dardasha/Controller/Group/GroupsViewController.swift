//
//  GroupsViewController.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit

class GroupsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeader: UILabel!
    
    var subscribedChannels = [Channel]()
    var myChannels : [Channel] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureViews()
        configureChannels()
    }
    
    private func configureViews(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChannelTableViewCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "MyChannelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyChannelCollectionViewCell")
        collectionView.register(UINib(nibName: "CreateChannelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreateChannelCollectionViewCell")
    }
    
    func configureChannels(){
        downloadMyChannels()
        downloadSubscribedChannels()
    }
    
    private func downloadSubscribedChannels(){
        FChannelListener.shared.downloadSubscribeChannels { subscribedChannels in
            self.subscribedChannels = subscribedChannels
            self.tableView.reloadData()
        }
    }
    
    private func downloadMyChannels(){
        FChannelListener.shared.downloadUserChannels { userChannels in
            self.myChannels = userChannels
            self.collectionView.reloadData()
        }
    }
    
    private func showChatView(channel:Channel){
        let channelVC = GroupMSGViewController(channel: channel)
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showCreateChannel(){
        guard let channelVC = storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") else {return}
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
}

extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        subscribedChannels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelTableViewCell
        let channel = subscribedChannels[indexPath.row]
        cell.configure(channel: channel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = subscribedChannels[indexPath.row]
        showChatView(channel: channel)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            var channelToUnfollow = subscribedChannels[indexPath.row]
            subscribedChannels.remove(at: indexPath.row)
            if let index = channelToUnfollow.memberIds.firstIndex(of: User.currentId){
                channelToUnfollow.memberIds.remove(at: index)
                FChannelListener.shared.saveChannel(channelToUnfollow)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
}

extension GroupsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myChannels.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row ==  myChannels.count {
            // Create Channel
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateChannelCollectionViewCell", for: indexPath) as! CreateChannelCollectionViewCell
            return cell
        }else{
            //My Channel
            let channel = myChannels[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChannelCollectionViewCell", for: indexPath) as! MyChannelCollectionViewCell
            cell.channelNameLbl.text = channel.name
            
            if channel.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: channel.avatarLink) { image in
                    DispatchQueue.main.async {
                        if image != nil{
                            cell.imageView.image = image!
                        }
                    }
                }
            }else{
                cell.imageView.image = UIImage(systemName: "person.circle.fill")
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == myChannels.count {
            // Create Channel
            showCreateChannel()
        }else {
            //My channel
            let channel = myChannels[indexPath.row]
            showChatView(channel: channel)
        }
    }
}
