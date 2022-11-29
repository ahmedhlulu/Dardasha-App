//
//  Extenstions.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import Foundation
import UIKit

extension UIImageView {
    
    func makeRounded() {
        
        contentMode = .scaleAspectFill
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}

extension Date {
    
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }
    
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func interval(ofComponent comp: Calendar.Component, to date: Date)-> Float {
        let currentCalender = Calendar.current
        
        guard let end = currentCalender.ordinality(of: comp, in: .era, for: date) else {return 0}
        guard let start = currentCalender.ordinality(of: comp, in: .era, for: self) else {return 0}
        
        return Float(end - start)
    }
    
}
