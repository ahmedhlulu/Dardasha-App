//
//  ChannelsTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 10/01/2023.
//

import UIKit

class ChannelsTableViewController: UITableViewController {

    @IBOutlet weak var channelSegment: UISegmentedControl!
    
    var subscribedChannels = [Channel]()
    var allChannels = [Channel]()
    var myChannels = [Channel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        configureChannel()
        
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        
        tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChannelTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureChannel()
    }

    
    @IBAction func channelSegmentChanged(_ sender: UISegmentedControl) {
        configureChannel()
    }
    
    func configureChannel(){
        downloadAllChannels()
        downloadMyChannels()
        downloadSubscribedChannels()
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if channelSegment.selectedSegmentIndex == 0 {
            return subscribedChannels.count
        } else if channelSegment.selectedSegmentIndex == 1 {
            return allChannels.count
        }else{
            return myChannels.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelTableViewCell
        var channel = Channel()
        if channelSegment.selectedSegmentIndex == 0 {
            channel = subscribedChannels[indexPath.row]
        } else if channelSegment.selectedSegmentIndex == 1 {
            channel = allChannels[indexPath.row]
        }else{
            channel = myChannels[indexPath.row]
        }
        cell.configure(channel: channel)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // MARK: - Download Channels
    private func downloadAllChannels(){
        FChannelListener.shared.downloadAllChannels { allChannels in
            self.allChannels = allChannels
            
            if self.channelSegment.selectedSegmentIndex == 1 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func downloadSubscribedChannels(){
        FChannelListener.shared.downloadSubscribeChannels { subscribedCahnnels in
            self.subscribedChannels = subscribedCahnnels
            
            if self.channelSegment.selectedSegmentIndex == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func downloadMyChannels(){
        FChannelListener.shared.downloadUserChannels(completion: { userChannels in
            self.myChannels = userChannels
            
            if self.channelSegment.selectedSegmentIndex == 2 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    // MARK: - Scrol view
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl!.isRefreshing {
            self.downloadAllChannels()
            refreshControl!.endRefreshing()
        }
    }
    
    
    // MARK: - TableView Delegate func
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if channelSegment.selectedSegmentIndex == 0 {
            showChatView(channel: subscribedChannels[indexPath.row])
        } else if channelSegment.selectedSegmentIndex == 1 {
            showFollowChannelView(channel: allChannels[indexPath.row])
        }else{
            showEditChannelView(channel: myChannels[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if channelSegment.selectedSegmentIndex == 1 || channelSegment.selectedSegmentIndex == 2 {
            return false
        }else {
            return subscribedChannels[indexPath.row].adminId != User.currentId
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
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
    
    // MARK: - Navigation
    private func showEditChannelView(channel:Channel){
        let channelVC = storyboard?.instantiateViewController(withIdentifier: "AddChannelTableViewController") as! AddChannelTableViewController
        
        channelVC.channelToEdit = channel
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showFollowChannelView(channel:Channel){
        let channelVC = storyboard?.instantiateViewController(withIdentifier: "ChannelFollowTableViewController") as! ChannelFollowTableViewController
        
        channelVC.channel = channel
        channelVC.followDelegate = self
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showChatView(channel:Channel){
        let channelVC = ChannelMSGViewController(channel: channel)
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
}

extension ChannelsTableViewController: ChannelFollowTableViewControllerDelegate{
    
    func didClickFollow() {
        self.downloadAllChannels()
    }
}
