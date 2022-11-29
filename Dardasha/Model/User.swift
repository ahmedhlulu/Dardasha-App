//
//  User.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct User : Codable, Equatable {
    var id = ""
    var username : String
    var email : String
    var pushId = ""
    var avatarLink = ""
    var status : String
    
    static var currentId : String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let data = userDefaults.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                do {
                    let userObject = try decoder.decode(User.self, from: data)
                    return userObject
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

func saveUserLocally(_ user : User){
    
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: kCURRENTUSER)
    }catch{
        print(error.localizedDescription)
    }
}


//func createDummyUsers(){
//
//    let names = ["Ahmed","Mohamed","Mohaned","Yousof","Nada"]
//
//    var imageIndex = 1
//    var userIndex = 1
//
//    for i in 0..<5 {
//        let id = UUID().uuidString
//
//        let fileDirectory = "Avatars/_\(id).jpg"
//
//        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { photoLink in
//
//            let user = User(id: id, username: names[i], email: "user\(userIndex)@gmail.com", pushId: "", avatarLink: photoLink ?? "", status: "Hi, I'm using Dardasha")
//
//            userIndex += 1
//            FUserListener.shared.saveUserToFirestore(user)
//        }
//
//        imageIndex += 1
//
//
//    }
//}
