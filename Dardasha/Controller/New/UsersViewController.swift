//
//  UsersViewController.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit

class UsersViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var allUsers = [User]()
    var filterUsers = [User]()
    
    var refreshControl = UIRefreshControl()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = .white
        
        definesPresentationContext = true
        searchController.searchResultsUpdater = self

        configureViews()
        downloadAllUsers()
    }
    

    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureViews(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "UsersTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Download Channels
    private func downloadAllUsers(){
        FUserListener.shared.downloadAllUserFromFirestore { allUsers in
            self.allUsers = allUsers
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Show Channel Info
    func showUserProfile(_ user: User){
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    // MARK: - Scrol view
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            self.downloadAllUsers()
            refreshControl.endRefreshing()
        }
    }
    
}

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        searchController.searchBar.text != "" ? filterUsers.count : allUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell", for: indexPath) as! UsersTableViewCell
        let user = searchController.searchBar.text != "" ? filterUsers[indexPath.row] : allUsers[indexPath.row]
                
        cell.configureCell(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = searchController.searchBar.text != "" ? filterUsers[indexPath.row] : allUsers[indexPath.row]
        showUserProfile(user)
    }
    
}

extension UsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        filterUsers = allUsers.filter({ user -> Bool in
            return user.username.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
}

