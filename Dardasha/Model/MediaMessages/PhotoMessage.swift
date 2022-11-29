//
//  PhotoMessage.swift
//  Dardasha
//
//  Created by Ahmed on 15/09/2022.
//

import Foundation
import MessageKit
import UIKit

class PhotoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init (path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = kPLACEHOLDERMESSAGEIMAGE
        self.size = CGSize(width: 240, height: 240)
        
    }
    
}
