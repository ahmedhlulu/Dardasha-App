//
//  ProfileViewController.swift
//  Dardasha
//
//  Created by Ahmed on 21/06/2023.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var emailTitleLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var memberDateTitleLbl: UILabel!
    @IBOutlet weak var memberDateLbl: UILabel!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.makeRounded()
        showUserInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    private func configureBackButtonItem(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.backward.fill"), style: .plain, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func editProfileClicked(_ sender: Any) {
        if let user = user {
            // from another view controller
            let chatId = startChat(sender: User.currentUser!, receiver: user)
            let privateMSGView = MSGViewController(chatId: chatId, recipientId: user.id, recipientName: user.username)
            privateMSGView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privateMSGView, animated: true)
            
        }else {
            guard let editProfile = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") else {return}
            navigationController?.pushViewController(editProfile, animated: true)
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        FUserListener.shared.logoutCurrentUser { error in
            if error == nil {
                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! UINavigationController
                loginView.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    self.present(loginView, animated: true)
                }
            }
        }
    }
    
    
    
    // MARK: - Update UI
    private func showUserInfo() {
        if let user = user {
            // from another view controller
            configureBackButtonItem()
            usernameLbl.text = user.username
            statusLbl.text = user.status
            memberDateLbl.text = timeElapsed(user.memberDate ?? Date())
            
            emailTitleLbl.isHidden = true
            emailLbl.isHidden = true
            memberDateTitleLbl.isHidden = true
            editProfileBtn.setTitle("Start Chat", for: .normal)
            
            if user.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                    self.avatarImageView.image = image
                }
            }
        }else{
            // current user
            if let user = User.currentUser{
                usernameLbl.text = user.username
                statusLbl.text = user.status
                emailLbl.text = user.email
                memberDateLbl.text = timeElapsed(user.memberDate ?? Date())
                
                emailTitleLbl.isHidden = false
                emailLbl.isHidden = false
                memberDateTitleLbl.isHidden = false
                memberDateLbl.isHidden = false
                logoutBtn.isHidden = false
                editProfileBtn.setTitle("Edit Profile", for: .normal)
                
                if user.avatarLink != "" {
                    FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                        self.avatarImageView.image = image
                    }
                }
            }
        }
    }
    

}
