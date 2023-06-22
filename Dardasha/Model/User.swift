//
//  User.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import Foundation
import FirebaseAuth

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

//
//func createDummyUsers(){
//
//    let names = [
//        "AllyTrotter",
//        "SantinoBenoit",
//        "NoelSewell",
//        "KinseySun",
//        "LonnieBledsoe",
//        "KalaRupp",
//        "DawsonKemper",
//        "HeidiGroff",
//        "BriceNoriega",
//        "RonniePoole",
//        "JimmyZhao",
//        "AiyanaCano",
//        "StewartSchneider",
//        "JeffersonNobles",
//        "MiguelangelChun",
//        "StefanieLester",
//        "RodrigoAbernathy",
//        "MeliaBarnhart",
//        "JalynVue",
//        "LianaPonce",
//    ]
//
//    let about = [
//
//                 "It is a long establisheby"
//                 ,"the readable content o point of using Lorem"
//                 ,"Ipsum is that it has aters, as opposed to using 'Content here,"
//                 ,"content here', making top publishing packages and web page"
//                 ,"editors now use Lorem  search for 'lorem ipsum' will"
//                 ,"uncover many web sitess have evolved over the years,"
//                 ,"sometimes by accident,"
//                 ,"Contrary to popular beext. It has roots in a piece of classical Latin"
//                 ,"literature from 45 BC,McClintock, a Latin professor at"
//                 ,"Hampden-Sydney Collegeobscure Latin words, consectetur, from a Lorem"
//                 ,"Ipsum passage, and goisical literature, discovered the undoubtable"
//                 ,"Ipsum passage, and goisical literature, discovered the undoubtable"
//                 ,"source. Lorem Ipsum co de Finibus Bonorum et Malorum"
//                 ,"(The Extremes of Good"
//                 ,"by Cicero, written in eory of ethics, very popular during the"
//                 ,"Renaissance. The firstsit amet.., comes from a line in  1.10.32."
//                 ,"The standard chunk of oduced below for those interested. Sections"
//                 ,"1.10.32 and 1.10.33 frro are also reproduced in their exact original"
//                 ,"1.10.32 and 1.10.33 frro are also reproduced in their exact original"
//                 ,"form, accompanied by En by H. Rackham."
//
//    ]
//
//    var userIndex = 1
//
//    for i in 0..<20 {
//        let id = UUID().uuidString
//
//        let fileDirectory = "Avatars/_\(id).jpg"
//
//        FileStorage.downloadImage(imageUrl: "https://picsum.photos/200") { image in
//            guard let image = image else {
//                print("error")
//                return
//            }
//            FileStorage.uploadImage(image, directory: fileDirectory) { photoLink in
//
//                let user = User(id: id, username: names[i], email: "user\(userIndex)@gmail.com", pushId: "\(Date().timeIntervalSince1970)", avatarLink: photoLink ?? "", status: about[i])
//
//                userIndex += 1
//                FUserListener.shared.saveUserToFirestore(user)
//            }
//
//        }
//
//
//
//
//    }
//}
//
//func createDummyChats(){
//
//    let names = [
//                 "Paris Aguirre",
//                 "Jayson Fitzpatrick",
//                 "Mallorie Fry",
//                 "Kyra Crawley",
//                 "Katarina Rockwell",
//                 "Kacie Benner",
//                 "Julisa Schoen",
//                 "Michael Xiong",
//                 "Marisol Dangelo",
//                 "Karolina Walsh",
//                 "Cain Carver",
//                 "Maiya Dowd",
//                 "Sam Bacon",
//                 "Thaddeus Askew",
//                 "Edna Linares",
//                 "Finn Pantoja",
//                 "Aric Putman",
//                 "Kameron Hudgins",
//                 "Shawn Artis",
//                 "Keyara Ayres",
//    ]
//
//    let about = [
//
//                 "It is a long established fact that a reader will be distracted by"
//                 ,"the readable content of a page when looking at its layout. The point of using Lorem"
//                 ,"Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here,"
//                 ,"content here', making it look like readable English. Many desktop publishing packages and web page"
//                 ,"editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will"
//                 ,"uncover many web sites still in their infancy. Various versions have evolved over the years,"
//                 ,"sometimes by accident, sometimes on purpose"
//                 ,"Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin"
//                 ,"literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at"
//                 ,"Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem"
//                 ,"Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable"
//                 ,"Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable"
//                 ,"source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum"
//                 ,"(The Extremes of Good and Evil)"
//                 ,"by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the"
//                 ,"Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in  1.10.32."
//                 ,"The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections"
//                 ,"1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original"
//                 ,"1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original"
//                 ,"form, accompanied by English versions from the 1914 translation by H. Rackham."
//
//    ]
//
//    var mimbers = [String]()
//
//    FUserListener.shared.downloadAllUserFromFirestore { allUsers in
//
//        allUsers.forEach { user in
//            mimbers.append(user.id)
//        }
//
//            for i in 0..<20 {
//                let id = UUID().uuidString
//
//                let fileDirectory = "Avatars/_\(id).jpg"
//
//                FileStorage.downloadImage(imageUrl: "https://picsum.photos/200") { image in
//                    guard let image = image else {
//                        print("error")
//                        return
//                    }
//                    FileStorage.uploadImage(image, directory: fileDirectory) { photoLink in
//                        let channel = Channel(id: id, name: names[i], adminId: mimbers.randomElement()!, memberIds: mimbers, avatarLink: photoLink ?? "", aboutChannel: about[i], createdDate: Date(), lastMessageDate: Date())
//                        FChannelListener.shared.saveChannel(channel)
//                    }
//                }
//            }
//    }
//
//}
