//
//  CreateGroupViewController.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit
import Gallery
import ProgressHUD

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var deleteChannelBtn: UIButton!
    
    var gallary: GalleryController!
    var avatarChange = false
    var channelId = UUID().uuidString
    var avatarLink = ""
    
    var channelToEdit: Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Create Group"
        configureBackButtonItem()
        avatarImageView.makeRounded()
        deleteChannelBtn.isHidden = true
        configuredEditView()
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if nameTF.text != "" {
            saveChannel()
        }else{
            ProgressHUD.showError("Group name is required")
        }
    }
    
    
    @IBAction func deleteChannelClicked(_ sender: Any) {
        guard channelToEdit != nil else {return}
        FChannelListener.shared.deleteChannel(channel: channelToEdit!) { error in
            guard error == nil else {
                ProgressHUD.showError(error!)
                return
            }
            ProgressHUD.showSuccess("Group Deleted")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func selectImageClicked(_ sender: Any) {
        showGallery()
    }
    
    
    private func configureBackButtonItem(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.backward.fill"), style: .plain, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Gallary
    private func showGallery(){
        self.gallary = GalleryController()
        self.gallary.delegate = self
        Config.tabsToShow = [.imageTab,.cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        self.present(gallary, animated: true)
    }
    
    // MARK: - Avatar
    private func uploadAvatarImage(_ image:UIImage, completion: @escaping (_ link: String)-> Void){
        let fileDirectory = "Avatars/_\(channelId).jpg"
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.7)! as NSData, fileName: self.channelId)
        FileStorage.uploadImage(image, directory: fileDirectory) { photoLink in
            completion(photoLink ?? "")
        }
    }
    
    
    // MARK: - Save channel
    private func saveChannel(){
        var channel = Channel(id: channelId,
                              name: nameTF.text!,
                              adminId: User.currentId,
                              memberIds: [User.currentId],
                              avatarLink: avatarLink,
                              aboutChannel: aboutTextView.text)
        if avatarChange {
            uploadAvatarImage(avatarImageView.image!) { link in
                channel.avatarLink = link
                FChannelListener.shared.saveChannel(channel)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            FChannelListener.shared.saveChannel(channel)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - configure edit view
    private func configuredEditView(){
        guard let channel = channelToEdit else {return}
        self.deleteChannelBtn.isHidden = false
        self.nameTF.text = channel.name
        self.channelId = channel.id
        self.aboutTextView.text = channel.aboutChannel
        self.avatarLink = channel.avatarLink
        self.title = "Editing (\(channel.name) Group)"
        
        
        if channel.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { image in
                DispatchQueue.main.async {
                    self.avatarImageView.image = image != nil ? image : UIImage(systemName: "person.circle.fill")
                }
            }
        }else{
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
}

extension CreateGroupViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0 {
            images.first!.resolve { image in
                if image != nil {
                    self.avatarChange = true
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
