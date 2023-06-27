//
//  RegisterViewController.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit
import ProgressHUD
import Gallery

class RegisterViewController: UIViewController {
        
    
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confermPassTF: UITextField!

    var gallery : GalleryController!
    
    var avatarChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundTapped()
        avatarImageView.applyshadowWithCorner(containerView: avatarView)
        
        usernameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        confermPassTF.delegate = self
        
        passwordTF.enablePasswordToggle()
        confermPassTF.enablePasswordToggle()
    }
    
    @IBAction func selectImageClicked(_ sender: Any) {
        showGallery()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        checkData() ? registerUser() : ProgressHUD.showError("All Fields are required")
    }
    
    // MARK: - showGallery
    private func showGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true)
    }
    
    // MARK: - Helper
    private func checkData () -> Bool {
        return emailTF.text != "" && passwordTF.text != "" && confermPassTF.text != "" && usernameTF.text != ""
    }
    
    private func setupBackgroundTapped(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard(){
        view.endEditing(false)
    }

    // MARK: - registerUser
    private func registerUser(){
        if passwordTF.text! == confermPassTF.text! {
            FUserListener.shared.registerUserWith(email: emailTF.text!, password: passwordTF.text!, username: usernameTF.text!.lowercased(), image: avatarChanged ? avatarImageView.image : nil) { error in
                if error != nil {
                    ProgressHUD.showError(error)
                }else{
                    ProgressHUD.showSuccess("Varification email send, please check your email")
                    self.passwordTF.text = ""
                    self.confermPassTF.text = ""
                    print(User.currentUser)
                }
            }
        }else {
            ProgressHUD.showError("Password is not same")
        }
    }
    
}

// MARK: - UIText Delegate
extension RegisterViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            ProgressHUD.showError("All Fields must not have space")
            return false
        }
        return true
    }
    
}


extension RegisterViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0 {
            images.first!.resolve { image in
                if image != nil {
                    self.avatarChanged = true
                    self.avatarImageView.image = image!
                }else{
                    ProgressHUD.showFailed("Could not select image")
                }
            }
        }
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)
    }
}
