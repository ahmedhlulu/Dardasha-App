//
//  ChatsTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 12/09/2022.
//

import UIKit

class ChatsTableViewController: UITableViewController {

    var allChatRooms:[ChatRoom] = []
    var filteredChatRooms:[ChatRoom] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadChatRooms()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        
    }
    
    
    @IBAction func startChatClicked(_ sender: UIBarButtonItem) {
        let userView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersTableViewController") as! UsersTableViewController
        userView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(userView, animated: true)
    }
    
    
    // MARK: - Func
    private func downloadChatRooms(){
        FChatRoomListener.shared.downloadChatRooms { allFBChatRooms in
            self.allChatRooms = allFBChatRooms
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func goToMSG(chatRoom: ChatRoom){
        // to make sure both users have chatrooms
        restartChat(chatRoomId: chatRoom.chatRoomId, memberIds: chatRoom.memberIds)
        
        let privateMSGView = MSGViewController(chatId: chatRoom.chatRoomId, recipientId: chatRoom.receiverId, recipientName: chatRoom.receiverName)
        
        navigationController?.pushViewController(privateMSGView, animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? filteredChatRooms.count : allChatRooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as! ChatTableViewCell
        let chatRoom = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        cell.configureCell(chatRoom: chatRoom)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let chatRoom = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
            FChatRoomListener.shared.deleteChatRoom(chatRoom)
            
            if searchController.isActive {
                filteredChatRooms.remove(at: indexPath.row)
            }else {
                allChatRooms.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatRoomObject = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        
        goToMSG(chatRoom: chatRoomObject)
    }

}

// MARK: - Extensions
extension ChatsTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredChatRooms = allChatRooms.filter({ chatRoom -> Bool in
            return chatRoom.receiverName.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
    
}
