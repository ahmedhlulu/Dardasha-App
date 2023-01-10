//
//  MessagesDisplayDelegate.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import MessageKit
import UIKit

extension MSGViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let bubbleColorOutgoing = UIColor(named: "ColorOutgoingBubble")!
        let bubbleColorIncoming = UIColor(named: "ColorIncomingBubble")!
        
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing : bubbleColorIncoming
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

// MARK: - Channel
extension ChannelMSGViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let bubbleColorOutgoing = UIColor(named: "ColorOutgoingBubble")!
        let bubbleColorIncoming = UIColor(named: "ColorIncomingBubble")!
        
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing : bubbleColorIncoming
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}
