//
//  AddChannelTableViewController.swift
//  Dardasha
//
//  Created by Ahmed on 10/01/2023.
//

import UIKit
import Gallery
import ProgressHUD

class AddChannelTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    
    var channelId = UUID().uuidString
    var gallary: GalleryController!
    var avatarLink = ""
    var tapGesture = UITapGestureRecognizer()
    
    var channelToEdit: Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        configureGestures()
        configureBackButtonItem()
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.makeRounded()
        configuredEditView()
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        if nameTF.text != "" {
            saveChannel()
        }else{
            ProgressHUD.showError("Channel name is required")
        }
    }
    
    
    private func configureGestures(){
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func avatarImageTap(){
        showGallery()
    }
    
    private func configureBackButtonItem(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))
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
    private func uploadAvatarImage(_ image:UIImage){
        let fileDirectory = "Avatars/_\(channelId).jpg"
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.7)! as NSData, fileName: self.channelId)
        FileStorage.uploadImage(image, directory: fileDirectory) { photoLink in
            self.avatarLink = photoLink ?? ""
        }
    }
    
    
    // MARK: - Save channel
    private func saveChannel(){
        let channel = Channel(id: channelId, name: nameTF.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutTextView.text)
        
        FChannelListener.shared.saveChannel(channel)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - configure edit view
    private func configuredEditView(){
        guard channelToEdit != nil else {return}
        
        self.nameTF.text = channelToEdit!.name
        self.channelId = channelToEdit!.id
        self.aboutTextView.text = channelToEdit!.aboutChannel
        self.avatarLink = channelToEdit!.avatarLink
        self.title = "Editing (\(channelToEdit!.name))"
        
        if channelToEdit!.avatarLink != "" {
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

extension AddChannelTableViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0 {
            images.first!.resolve { image in
                if image != nil {
                    self.uploadAvatarImage(image!)
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
