//
//  InputBarAccessoryViewDelegate.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import InputBarAccessoryView

extension MSGViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        updateMicButtonStatus(show: text == "")
        
        if text != "" {
            startTypingIndicator()
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        send(text: text, photo: nil, video: nil, audio: nil, location: nil)
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

// MARK: - Channel
extension GroupMSGViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        updateMicButtonStatus(show: text == "")
        
//        if text != "" {
//            startTypingIndicator()
//        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        send(text: text, photo: nil, video: nil, audio: nil, location: nil)
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
