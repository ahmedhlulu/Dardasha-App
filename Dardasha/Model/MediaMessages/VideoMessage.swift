//
//  VideoMessage.swift
//  Dardasha
//
//  Created by Ahmed on 13/10/2022.
//

import Foundation
import MessageKit
import UIKit

class VideoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init (url: URL?) {
        self.url = url
        self.placeholderImage = kPLACEHOLDERMESSAGEIMAGE
        self.size = CGSize(width: 240, height: 240)
        
    }
    
}
