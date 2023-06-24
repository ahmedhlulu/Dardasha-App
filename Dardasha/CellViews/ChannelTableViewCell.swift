//
//  ChannelTableViewCell.swift
//  Dardasha
//
//  Created by Ahmed on 10/01/2023.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var channelNameLbl: UILabel!
    @IBOutlet weak var aboutChannelLbl: UILabel!
    @IBOutlet weak var membersLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(channel: Channel){
        channelNameLbl.text = channel.name
        aboutChannelLbl.text = channel.aboutChannel
        membersLbl.text = "\(channel.memberIds.count) members"
        dateLbl.text = timeElapsed(channel.lastMessageDate ?? Date())
        if channel.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: channel.avatarLink) { image in
                DispatchQueue.main.async {
                    if image != nil{
                        self.avatarImageView.image = image!
                    }
                }
            }
        }else{
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

}
