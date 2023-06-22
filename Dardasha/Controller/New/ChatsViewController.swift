//
//  ChatsViewController.swift
//  Dardasha
//
//  Created by Ahmed on 21/06/2023.
//

import UIKit

class ChatsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
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
        
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = .white
        
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
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
    
    
    
}

// MARK: - Extensions
extension ChatsViewController : UISearchResultsUpdating ,UITableViewDelegate, UITableViewDataSource{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredChatRooms = allChatRooms.filter({ chatRoom -> Bool in
            return chatRoom.receiverName.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
  
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.searchBar.text != "" ? filteredChatRooms.count : allChatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as! ChatTableViewCell
        let chatRoom = searchController.searchBar.text != "" ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        cell.configureCell(chatRoom: chatRoom)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let chatRoom = searchController.searchBar.text != "" ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
            FChatRoomListener.shared.deleteChatRoom(chatRoom)
            
            if searchController.searchBar.text != "" {
                filteredChatRooms.remove(at: indexPath.row)
            }else {
                allChatRooms.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatRoomObject = searchController.searchBar.text != "" ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        
        goToMSG(chatRoom: chatRoomObject)
    }
    
    
}


