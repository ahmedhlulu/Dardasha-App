//
//  FUserListener.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import Foundation
import FirebaseAuth
import RealmSwift

class FUserListener {
    
    static let shared = FUserListener()
    
    private init (){}
    
    
    // TODO: Login
    func loginUserWith(email:String, password:String, completion: @escaping (_ error:Error?,_ isEmailVerified : Bool)-> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard error == nil && authResult!.user.isEmailVerified else {
                completion(error, false)
                return
            }
            completion(nil, true)
            self.downloadUserFromFirestore(userId: authResult!.user.uid)
        }
    }
    
    
    // TODO: Register
    func registerUserWith(email:String, password:String, username:String,image: UIImage?, completion: @escaping (_ error:Error?)-> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResults, error in
            guard let result = authResults, error == nil else {
                completion(error)
                return
            }
            
            
            result.user.sendEmailVerification { error in
                if error != nil{
                    completion(error)
                }
            }
            
            var user = User(id: result.user.uid,
                            username: username,
                            email: email,
                            memberDate: Date(),
                            avatarLink: "",
                            status: "Welcome, I'm \(username)")
            
            if let image = image {
                let fileDirectory = "Avatars/_\(result.user.uid).jpg"
                FileStorage.uploadImage(image, directory: fileDirectory) { photoLink in
                    user.avatarLink = photoLink ?? ""
                    self.saveUserToFirestore(user)
                    saveUserLocally(user)
                }
            }else {
                self.saveUserToFirestore(user)
                saveUserLocally(user)
            }
        }
    }
    
    // MARK: - resendLinkVerification
    func resendLinkVerification(email : String, completion: @escaping(_ error : Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                completion(error)
            })
        })
    }
    
    // MARK: - resetPassword
    func resetPassword(email:String, comletion: @escaping (_ error : Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            comletion(error)
        }
    }
    
    // MARK: - logout
    func logoutCurrentUser(completion: @escaping (_ error : Error?) -> Void){
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        }catch{
            completion(error)
        }
    }
    
    // MARK: - saveUserToFirestore
    func saveUserToFirestore(_ user: User){
        do {
            try FirestoreReference(.User).document(user.id).setData(from: user)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - downloadUserFromFirestore
    private func downloadUserFromFirestore(userId:String){
        FirestoreReference(.User).document(userId).getDocument { document, error in
            guard let userDocument = document else {
                print("No data found")
                return
            }
            let result = Result {
                try? userDocument.data(as: User.self)
            }
            
            switch result {
            case .success(let user):
                if user != nil {
                    saveUserLocally(user!)
                }else {
                    print("Document not exist")
                }
            case .failure(let error):
                print("Error decoding user: ",error.localizedDescription)
            }
        }
    }
    
    func downloadUserFromFirestoreWith(userId:String, completion: @escaping (_ user: User) -> Void){
        FirestoreReference(.User).document(userId).getDocument { document, error in
            guard let userDocument = document else {
                print("No data found")
                return
            }
            let result = Result {
                try? userDocument.data(as: User.self)
            }
            
            switch result {
            case .success(let user):
                    guard let user = user else {
                        print("Document not exist")
                        return
                    }
                    completion(user)
            case .failure(let error):
                print("Error decoding user: ",error.localizedDescription)
            }
        }
    }
    
    func downloadUsersFromFirestore(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void){
        
        var count = 0
        var userArray = [User]()
        
        withIds.forEach { userId in
            FirestoreReference(.User).document(userId).getDocument { documentSnapshot, error in
                guard let document = documentSnapshot else {return}
                let user = try? document.data(as: User.self)
                guard let user = user else {return}
                userArray.append(user)
                count += 1
                
                if count == withIds.count {
                    completion(userArray)
                }
            }
        }
    }
    
    func downloadAllUserFromFirestore(completion: @escaping (_ allUsers: [User]) -> Void){
        
        var users: [User] = []
        
        FirestoreReference(.User).getDocuments { snapShot, error in
            guard let document = snapShot?.documents else {
                print("No document found")
                return
            }
            
            let allUsersDocument = document.compactMap { queryDocumentSnapshot -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            for user in allUsersDocument {
                if user.id != User.currentId {
                    users.append(user)
                }
            }
            completion(users)
        }
    }
}
