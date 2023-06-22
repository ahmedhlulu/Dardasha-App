//
//  TFExtenstion.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import Foundation
import UIKit

class TFExtenstion : UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeRound()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        makeRound()
    }
    
    func makeRound(){
        self.layer.borderWidth = CGFloat(1.2)
        self.layer.cornerRadius = 12
        
    }
    
}
