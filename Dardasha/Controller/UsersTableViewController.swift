//
//  UsersTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 12/09/2022.
//

import UIKit

class UsersTableViewController: UITableViewController {

    var allUsers = [User]()
    var filterUsers = [User]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadUsers()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
    }
    
    // MARK: - Func
    func downloadUsers(){
        FUserListener.shared.downloadAllUserFromFirestore { allUsers in
            self.allUsers = allUsers
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func showUserProfile(user: User){
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        profileView.user = user
        navigationController?.pushViewController(profileView, animated: true)
    }
    
    // MARK: - UIScroll Delegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing {
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }

    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filterUsers.count : allUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell") as! UsersTableViewCell
        let user = searchController.isActive ? filterUsers[indexPath.row] : allUsers[indexPath.row]
        cell.configureCell(user: user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = searchController.isActive ? filterUsers[indexPath.row] : allUsers[indexPath.row]
        showUserProfile(user: user)
    }
}

// MARK: - Extensions
extension UsersTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterUsers = allUsers.filter({ user -> Bool in
            return user.username.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
    
}
