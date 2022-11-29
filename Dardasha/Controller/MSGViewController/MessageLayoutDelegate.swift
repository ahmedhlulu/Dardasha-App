//
//  MessageLayoutDelegate.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import MessageKit

extension MSGViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            if (indexPath.section == 0) && (allLocalMessages.count > displayMessagesCount) {
                return 40
            }
        }
        
        return 10
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section == mkMessages.count - 1 ? (isFromCurrentSender(message: message) ? 17 : 0) : 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.set(avatar: Avatar(image: nil, initials: mkMessages[indexPath.section].senderInitials.uppercased()))
    }
    
}
