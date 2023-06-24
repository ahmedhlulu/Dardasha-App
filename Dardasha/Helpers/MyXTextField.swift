//
//  TFExtenstion.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import Foundation
import UIKit

class MyXTextField : UITextField {
    
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
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 12
        self.backgroundColor = UIColor(named: "ColorTextField")
    }
    
}


class MyXTextView : UITextView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        makeRound()
    }
    
    func makeRound(){
        self.layer.borderWidth = CGFloat(1.2)
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 12
        self.backgroundColor = UIColor(named: "ColorTextField")
    }
    
}
