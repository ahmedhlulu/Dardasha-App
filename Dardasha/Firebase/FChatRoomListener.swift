//
//  FChatRoomListener.swift
//  Dardasha
//
//  Created by Ahmed on 12/09/2022.
//

import Foundation
import FirebaseFirestore

class FChatRoomListener {
    
    static let shared = FChatRoomListener()
    private init (){}
    
    func saveChatRoom(_ chatRoom: ChatRoom){
        do {
            try FirestoreReference(.Chat).document(chatRoom.id).setData(from: chatRoom)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - download all chatrooms
    func downloadChatRooms(completion: @escaping (_ allFBChatRooms: [ChatRoom]) -> Void) {
        FirestoreReference(.Chat).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { querySnapshot, error in
            
            var chatRooms:[ChatRoom] = []
            guard let documents = querySnapshot?.documents else {
                print("No document found")
                return
            }
            let allFirebaseChatRooms = documents.compactMap { queryDocumentSnapshot -> ChatRoom? in
                return try? queryDocumentSnapshot.data(as: ChatRoom.self)
            }
            
            for chatRoom in allFirebaseChatRooms {
                
                if chatRoom.lastMessage != "" {
                    chatRooms.append(chatRoom)
                }
            }
            chatRooms.sort(by: {$0.date! > $1.date!})
            completion(chatRooms)
        }
    }
    
    // MARK: - Delete chat
    func deleteChatRoom(_ chatRoom: ChatRoom){
        FirestoreReference(.Chat).document(chatRoom.id).delete()
    }
    
    // MARK: - reset unread conter
    func clearUnreadCounter(chatRoom: ChatRoom){
        var newChatRoom = chatRoom
        newChatRoom.unreadCounter = 0
        self.saveChatRoom(newChatRoom)
    }
    
    func clearUnreadCounterUsingChatRoomId(chatRoomId: String){
        FirestoreReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {return}
            
            let allChatRooms = documents.compactMap { queryDocumentSnapshot -> ChatRoom? in
                return try? queryDocumentSnapshot.data(as: ChatRoom.self)
            }
            if allChatRooms.count > 0 {
                self.clearUnreadCounter(chatRoom: allChatRooms.first!)
            }
        }
    }
    
    // MARK: - update chatroom with new message
    func updateChatRoomWithNewMessage(chatRoom: ChatRoom, lastMessage: String){
        var tempChatRoom = chatRoom
        if tempChatRoom.senderId != User.currentId {
            tempChatRoom.unreadCounter += 1
        }
        
        tempChatRoom.lastMessage = lastMessage
        tempChatRoom.date = Date()
        self.saveChatRoom(tempChatRoom)
    }
    
    func updateChatRooms(chatRoomId: String, lastMessage: String){
        FirestoreReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { querySnapshot, error in
            guard let document = querySnapshot?.documents else {return}
            
            let allChatRooms = document.compactMap { queryDocumentSnapshot -> ChatRoom? in
                return try? queryDocumentSnapshot.data(as: ChatRoom.self)
            }
            
            for room in allChatRooms {
                self.updateChatRoomWithNewMessage(chatRoom: room, lastMessage: lastMessage)
            }
        }
    }
    
}
