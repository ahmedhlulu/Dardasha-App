//
//  FTypingListener.swift
//  Dardasha
//
//  Created by Ahmed on 14/09/2022.
//

import Foundation
import Firebase

class FTypingListener {
    
    static let shared = FTypingListener()
    
    var typingListener: ListenerRegistration!
    
    private init(){}
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool)->Void){
        
        typingListener = FirestoreReference(.Typing).document(chatRoomId).addSnapshotListener({ documentSnapshot, error in
            guard let snapshot = documentSnapshot else {return}
            
            if snapshot.exists {
                
                for data in snapshot.data()! {
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            }else {
                completion(false)
                FirestoreReference(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    func saveTypingCounter(typing: Bool, chatRoomId: String){
        FirestoreReference(.Typing).document(chatRoomId).updateData([User.currentId: typing])
    }
    
    func removeTypingListener(){
        self.typingListener.remove()
    }
    
}
