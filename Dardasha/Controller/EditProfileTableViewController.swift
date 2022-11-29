//
//  EditProfileTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var statusTF: UITextField!
    
    var gallery : GalleryController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.makeRounded()
        setupBackgroundTapped()
        tableView.tableFooterView = UIView()
        showUserInfo()
        usernameTF.delegate = self
        statusTF.delegate = self
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
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "ColorTableView")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.0
    }
    
}

extension EditProfileTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTF {
            statusTF.becomeFirstResponder()
        }else {
            view.endEditing(false)
        }
        return true
    }
}

extension EditProfileTableViewController : GalleryControllerDelegate {
    
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
