//
//  ChatRoom.swift
//  Dardasha
//
//  Created by Ahmed on 12/09/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatRoom: Codable {
    
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
}
