//
//  EditProfileViewController.swift
//  Dardasha
//
//  Created by Ahmed on 21/06/2023.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var statusTF: UITextView!
    
    var gallery : GalleryController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        avatarImageView.applyshadowWithCorner(containerView: avatarView)
        setupBackgroundTapped()
        showUserInfo()
        usernameTF.delegate = self
        statusTF.delegate = self
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func editImageClicked(_ sender: Any) {
        showGallery()
    }
    

    @IBAction func editProfileClicked(_ sender: Any) {
        saveUser()
    }
    
    private func showUserInfo(){
        if let user = User.currentUser {
            usernameTF.text = user.username
            statusTF.text = user.status
            
            if user.avatarLink != "" {
                
                FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                    self.avatarImageView.image = image
                }
            }
        }
    }
    
    // MARK: - Save user
    private func saveUser(){
        if var user = User.currentUser {
            if usernameTF.text != "" {
                user.username = usernameTF.text!
            }
            if statusTF.text != "" {
                user.status = statusTF.text!
            }
            saveUserLocally(user)
            FUserListener.shared.saveUserToFirestore(user)
            navigationController?.popViewController(animated: true)
        }
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
    
    private func updateImage(image: UIImage){
        let fileDirectory = "Avatars/_\(User.currentId).jpg"
        
        if var user = User.currentUser {
            FileStorage.uploadImage(image, directory: fileDirectory) { photoLink in
                
                user.avatarLink = photoLink ?? ""
                saveUserLocally(user)
                FUserListener.shared.saveUserToFirestore(user)
            }
            
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.5)! as NSData, fileName: User.currentId)
        }
    }
    
    // MARK: - Helper
    private func setupBackgroundTapped(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard(){
        view.endEditing(false)
    }
    
    
}

extension EditProfileViewController : UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTF {
            statusTF.becomeFirstResponder()
        }else {
            view.endEditing(false)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameTF {
            if string == " " {
                ProgressHUD.showError("Username must not have space")
                return false
            } else {
                return true
            }
        }
        return true
    }
    
}

extension EditProfileViewController : GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { avatarImage in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!
                    self.updateImage(image: avatarImage!)
                }else {
                    ProgressHUD.showError("Could now select image")
                }
            }
        }
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true)
    }
    
}
