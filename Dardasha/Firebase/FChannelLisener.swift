//
//  FChannelLisener.swift
//  Dardasha
//
//  Created by Ahmed on 10/01/2023.
//

import Foundation
import Firebase

class FChannelListener {
    
    static let shared = FChannelListener()
    var userChannelsListener: ListenerRegistration!
    var subscribeChannelsListener: ListenerRegistration!
    
    private init(){}
    
    // MARK: - add Channel
    func saveChannel(_ channel:Channel){
        do {
            try FirestoreReference(.Channel).document(channel.id).setData(from: channel)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Download channels
    func downloadUserChannels(completion: @escaping(_ userChannels:[Channel]) -> Void){
        
        userChannelsListener = FirestoreReference(.Channel).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener({ querySnapshot, error in
            
            guard let document = querySnapshot?.documents else { return }
            
            var userCahnnels = document.compactMap { queryDocumentSnapshot -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            userCahnnels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(userCahnnels)
        })
    }
    
    func downloadSubscribeChannels(completion: @escaping(_ subscribedCahnnels:[Channel]) -> Void){
        
        subscribeChannelsListener = FirestoreReference(.Channel).whereField(kMEMBERIDS, arrayContains: User.currentId).addSnapshotListener({ querySnapshot, error in
            
            guard let document = querySnapshot?.documents else { return }
            
            var subscribedCahnnels = document.compactMap { queryDocumentSnapshot -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            subscribedCahnnels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(subscribedCahnnels)
        })
    }
    
    func downloadAllChannels(completion: @escaping(_ allChannels:[Channel]) -> Void){
        
        FirestoreReference(.Channel).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents  else {return}
            
            var allChannels = documents.compactMap { queryDocumentSnapshot -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels = self.removeUserChannels(allChannels)
            allChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(allChannels)
        }
    }
    
    
    // MARK: - Helper func
    func removeUserChannels(_ allChannels: [Channel]) -> [Channel] {
        
        var newChannels = [Channel]()
        
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        return newChannels
    }
    
}
