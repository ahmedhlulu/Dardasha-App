//
//  HomeView.swift
//  Dardasha
//
//  Created by Ahmed on 21/06/2023.
//

import UIKit

class MyXView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        mackRounded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mackRounded()
    }
    
    func mackRounded(){
        self.layer.cornerRadius = 30
    }

}

class AvatarViewShadow: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        mackRounded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mackRounded()
    }
    
    func mackRounded(){
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.cornerRadius = 20
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
    }
}
