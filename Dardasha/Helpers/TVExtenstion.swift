//
//  TFExtenstion.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import Foundation
import UIKit

class TVExtenstion : UITextView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        makeRound()
    }
    
    func makeRound(){
        self.layer.borderWidth = CGFloat(2)
        self.layer.cornerRadius = 20
        
    }
    
}
