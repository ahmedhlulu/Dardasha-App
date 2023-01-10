//
//  Outgoing.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery

class Outgoing {
    
    class func sendMessage(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0,location: String?, memberIds: [String]){
        
        //create local message from data we have
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderinitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        //check message type
        if text != nil {
            sendText(message: message, text: text!, memberIds: memberIds)
        }
        if photo != nil {
            sendPhoto(message: message, photo: photo!, memberIds: memberIds)
        }
        if video != nil {
            sendVideo(message: message, video: video!, memberIds: memberIds)
        }
        if location != nil {
            sendLocation(message: message, memberIds: memberIds)
        }
        if audio != nil {
            sendAudio(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        //save message locally
        
        
        //save message to firestore
        
        
        // TODO: send push notification
        
        FChatRoomListener.shared.updateChatRooms(chatRoomId: chatId, lastMessage: message.message)
    }
    
    // MARK: - send Channel Messgae
    class func sendChannelMessage(channel: Channel, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0,location: String?){
        
        //create local message from data we have
        var channel = channel
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = channel.id
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderinitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        //check message type
        if text != nil {
            sendText(message: message, text: text!, memberIds: channel.memberIds,channel: channel)
        }
        if photo != nil {
            sendPhoto(message: message, photo: photo!, memberIds: channel.memberIds,channel: channel)
        }
        if video != nil {
            sendVideo(message: message, video: video!, memberIds: channel.memberIds,channel: channel)
        }
        if location != nil {
            sendLocation(message: message, memberIds: channel.memberIds,channel: channel)
        }
        if audio != nil {
            sendAudio(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: channel.memberIds,channel: channel)
        }
        
        //save message locally
        
        
        //save message to firestore
        
        
        // TODO: send push notification
        channel.lastMessageDate = Date()
        FChannelListener.shared.saveChannel(channel)
    }
    
    
    class func saveMessage(message: LocalMessage, memberIds: [String]){
        RealmManager.shared.save(message)
        
        for memberId in memberIds {
            FMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
    
    class func saveChannelMessage(message: LocalMessage, channel:Channel){
        RealmManager.shared.save(message)
        
        
        FMessageListener.shared.addChannelMessage(message, channel: channel)
        
    }
    
    
}

func sendText(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil){
    message.message = text
    message.type = kTEXT
    
    if channel != nil{
        Outgoing.saveChannelMessage(message: message, channel: channel!)
    }else{
        Outgoing.saveMessage(message: message, memberIds: memberIds)
    }
}

func sendPhoto(message: LocalMessage, photo: UIImage, memberIds: [String], channel: Channel? = nil){
    message.message = "Photo Message"
    message.type = kPHOTO
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/\(message.chatRoomId)_\(fileName).jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    FileStorage.uploadImage(photo, directory: fileDirectory) { photoLink in
        if photoLink != nil {
            message.pictureUrl = photoLink!
            if channel != nil{
                Outgoing.saveChannelMessage(message: message, channel: channel!)
            }else{
                Outgoing.saveMessage(message: message, memberIds: memberIds)
            }
        }
    }
}

func sendVideo(message: LocalMessage, video: Video, memberIds: [String], channel: Channel? = nil){
    message.message = "Video Message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/\(message.chatRoomId)_\(fileName).jpg"
    let videoDirectory = "MediaMessages/Video/\(message.chatRoomId)_\(fileName).mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { proccessedVideo, videoUrl in
        if let tempPath = videoUrl {
            let thumbnail = videoThumbnail(videoURL: tempPath)
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory,showProgress: false) { photoLink in
                if photoLink != nil {
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { videoLink in
                        message.videoUrl = videoLink ?? ""
                        message.pictureUrl = photoLink ?? ""
                        if channel != nil{
                            Outgoing.saveChannelMessage(message: message, channel: channel!)
                        }else{
                            Outgoing.saveMessage(message: message, memberIds: memberIds)
                        }
                    }
                }
            }
        }
    }
}

func sendLocation(message: LocalMessage, memberIds: [String], channel: Channel? = nil){
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location Message"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    if channel != nil{
        Outgoing.saveChannelMessage(message: message, channel: channel!)
    }else{
        Outgoing.saveMessage(message: message, memberIds: memberIds)
    }
}

func sendAudio(message: LocalMessage, audioFileName: String, audioDuration: Float, memberIds: [String], channel: Channel? = nil){
    
    message.message = "Audio Message"
    message.type = kAUDEO
    let fileDirectory = "MediaMessages/Audio/\(message.chatRoomId)_\(audioFileName).m4a"
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { audioLink in
        if audioLink != nil {
            message.audioUrl = audioLink ?? ""
            message.audioDuration = Double(audioDuration)
            
            if channel != nil{
                Outgoing.saveChannelMessage(message: message, channel: channel!)
            }else{
                Outgoing.saveMessage(message: message, memberIds: memberIds)
            }
        }
    }
}
