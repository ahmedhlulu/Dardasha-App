//
//  MyChannelCollectionViewCell.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit

class MyChannelCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var channelNameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.makeRounded()
    }

}
