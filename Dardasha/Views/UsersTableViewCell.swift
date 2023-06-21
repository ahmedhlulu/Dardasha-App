//
//  UsersTableViewCell.swift
//  Dardasha
//
//  Created by Ahmed on 12/09/2022.
//

import UIKit
import RealmSwift

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: User){
        
        usernameLbl.text = user.username
        statusLbl.text = user.status
        
        if user.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                self.avatarImageView.image = image
            }
        }else {
            self.avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

}
