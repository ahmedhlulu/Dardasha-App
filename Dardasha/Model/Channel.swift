//
//  Channel.swift
//  Dardasha
//
//  Created by Ahmed on 10/01/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Channel: Codable {
    
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createdDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
        case createdDate
        case lastMessageDate = "date"
    }
}
