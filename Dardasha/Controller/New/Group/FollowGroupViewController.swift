//
//  FollowGroupViewController.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit

class FollowGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var allChannels = [Channel]()
    var filteredChannels :[Channel] = []
    
    var refreshControl = UIRefreshControl()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Groups"
        
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = .white
        
        definesPresentationContext = true
        searchController.searchResultsUpdater = self

        configureViews()
        downloadAllChannels()
    }
    

    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureViews(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChannelTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Download Channels
    private func downloadAllChannels(){
        FChannelListener.shared.downloadAllChannels { allChannels in
            self.allChannels = allChannels
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Show Channel Info
    func showChannelInfo(channel: Channel){
        FUserListener.shared.downloadUsersFromFirestore(withIds: channel.memberIds) { allUsers in
            let channelVC = self.storyboard?.instantiateViewController(withIdentifier: "AboutGroupViewController") as! AboutGroupViewController
            channelVC.channel = channel
            channelVC.users = allUsers
            self.navigationController?.pushViewController(channelVC, animated: true)
        }
    }
    
    // MARK: - Scrol view
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            self.downloadAllChannels()
            refreshControl.endRefreshing()
        }
    }
    
}

extension FollowGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        searchController.searchBar.text != "" ? filteredChannels.count : allChannels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelTableViewCell
        let channel = searchController.searchBar.text != "" ? filteredChannels[indexPath.row] : allChannels[indexPath.row]
                
        cell.configure(channel: channel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = searchController.searchBar.text != "" ? filteredChannels[indexPath.row] : allChannels[indexPath.row]
        showChannelInfo(channel: channel)
    }
    
}

extension FollowGroupViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredChannels = allChannels.filter({ channel -> Bool in
            return channel.name.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
}
