//
//  FMessageListener.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FMessageListener {
    
    static let shared = FMessageListener()
    var newMessageListener : ListenerRegistration!
    var updatedMessageListener : ListenerRegistration!
    
    private init (){}
    
    func addMessage(_ message: LocalMessage, memberId: String){
        do {
            try FirestoreReference(.Message).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }catch{
            print("Error saving message to firestore: ",error.localizedDescription)
        }
    }
    
    func checkForOldMessages(documentId: String, collectionId: String){
        FirestoreReference(.Message).document(documentId).collection(collectionId).getDocuments { querySnapshot, error in
            guard let document = querySnapshot?.documents else {return}
            
            var oldMessages = document.compactMap { queryDocumentSnapshot -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: {$0.date < $1.date})
            
            for messgae in oldMessages {
                RealmManager.shared.save(messgae)
            }
        }
    }
    
    func listenForNewMessages(_ documentId: String, collectionId: String, lastMessageDate: Date){
        newMessageListener = FirestoreReference(.Message).document(documentId).collection(collectionId).whereField("date", isGreaterThan: lastMessageDate).addSnapshotListener({ querySnapshot, error in
            guard let snapshot = querySnapshot else {return}
            
            for change in snapshot.documentChanges {
                if change.type == .added {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let success):
                        if let message = success {
                            if message.senderId != User.currentId {
                                RealmManager.shared.save(message)
                            }
                        }
                        
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
        })
    }
    
    func updateMessageStatus(message: LocalMessage, userId: String){
        let valus = [kSTATUS: kREAD, kREADDATE: Date()] as [String: Any]
        
        FirestoreReference(.Message).document(userId).collection(message.chatRoomId).document(message.id).updateData(valus)
    }
    
    func listenForReadStatus(_ documentId: String, collectionId: String, competion: @escaping (_ updatedMessage: LocalMessage) -> Void){
        updatedMessageListener = FirestoreReference(.Message).document(documentId).collection(collectionId).addSnapshotListener({ querySnapshot, error in
            guard let snapshot = querySnapshot else {return}
            
            for change in snapshot.documentChanges {
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            competion(message)
                        }
                        
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
        })
    }
    
    func removeNewMessgaeListener(){
        self.newMessageListener.remove()
        self.updatedMessageListener.remove()
    }
    
}
