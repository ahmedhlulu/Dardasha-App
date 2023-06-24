//
//  ChatTableViewCell.swift
//  Dardasha
//
//  Created by Ahmed on 12/09/2022.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var messageCounterView: UIView!
    @IBOutlet weak var messageCounterLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.makeRounded()
        messageCounterView.layer.cornerRadius = messageCounterView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(chatRoom: ChatRoom) {
        usernameLbl.text = chatRoom.receiverName
        lastMessageLbl.text = chatRoom.lastMessage
        
        if chatRoom.unreadCounter != 0 {
            messageCounterLbl.text = chatRoom.unreadCounter >= 100 ? "+99" : "\(chatRoom.unreadCounter)"
            messageCounterView.isHidden = false
        }else {
            messageCounterView.isHidden = true
        }
        
        if chatRoom.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: chatRoom.avatarLink) { image in
                self.avatarImageView.image = image
            }
        }else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        dateLbl.text = timeElapsed(chatRoom.date ?? Date())
    }

}
