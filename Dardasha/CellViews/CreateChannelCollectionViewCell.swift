//
//  MyChannelCollectionViewCell.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit

class CreateChannelCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var createLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.makeRounded()
    }

}
