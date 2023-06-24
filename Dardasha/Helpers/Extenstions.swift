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
        layer.borderColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1).cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
    
    func applyshadowWithCorner(containerView : UIView){
            containerView.clipsToBounds = false
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowOffset = CGSize.zero
            containerView.layer.shadowRadius = 10
        containerView.layer.cornerRadius = self.frame.width / 2
            containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: self.frame.width / 2).cgPath
            self.clipsToBounds = true
            self.layer.cornerRadius = self.frame.width / 2
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


extension UITextField {
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry){
            button.setImage(UIImage(systemName: "eye"), for: .normal)
            //button.setTitle("show ", for: .normal)
        }else{
            button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            //button.setTitle("hide ", for: .normal)
            
        }
    }
    
    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.backgroundColor = UIColor(named: "AccentColor")
        button.tintColor = .white
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}

extension UISearchBar {
    
    func setColorAndPlaceholder(placeholder: String){
        self.placeholder = placeholder
        self.searchTextField.backgroundColor = UIColor(named: "ColorTextField")
        self.tintColor = .label
        self.barStyle = .black
    }
}
