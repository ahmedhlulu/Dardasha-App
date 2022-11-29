//
//  Incoming.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import MessageKit
import CoreLocation

class Incoming {
    
    var messageViewController: MessagesViewController
    
    init (messageViewController : MessagesViewController) {
        self.messageViewController = messageViewController
    }
    
    func createMKMessage(localMessage: LocalMessage) -> MKMessage {
        let mkMessage = MKMessage.init(message: localMessage)
        
        if localMessage.type == kPHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { image in
                mkMessage.photoItem?.image = image
                self.messageViewController.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kVIDEO {
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { thumbnail in
                FileStorage.downloadVideo(videoUrl: localMessage.videoUrl) { isReadyToPlay, videoFileName in
                    
                    let videoLink = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: videoFileName))
                    let videoItem = VideoMessage(url: videoLink)
                    
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                    mkMessage.videoItem?.image = thumbnail
                    self.messageViewController.messagesCollectionView.reloadData()
                }
            }
        }
        
        if localMessage.type == kLOCATION {
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        if localMessage.type == kAUDEO {
            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))
            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)
            
            FileStorage.downloadAudio(audioUrl: localMessage.audioUrl) { audioFileName in
                let audioUrl = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: audioFileName))
                mkMessage.audioItem?.url = audioUrl
                self.messageViewController.messagesCollectionView.reloadData()
            }
        }
        
        return mkMessage
    }
    
    
}
