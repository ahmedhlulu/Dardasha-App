//
//  HomeView.swift
//  Dardasha
//
//  Created by Ahmed on 21/06/2023.
//

import UIKit

class HomeView: UIView {

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
