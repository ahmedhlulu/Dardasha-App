//
//  RegisterViewController.swift
//  Dardasha
//
//  Created by Ahmed on 22/06/2023.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {
        
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confermPassTF: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupBackgroundTapped()
        usernameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        confermPassTF.delegate = self
        
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        checkData() ? registerUser() : ProgressHUD.showError("All Fields are required")
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
            FUserListener.shared.registerUserWith(email: emailTF.text!, password: passwordTF.text!, username: usernameTF.text!.lowercased()) { error in
                guard error == nil else {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            }
            ProgressHUD.showSuccess("Varification email send, please check your email")
            passwordTF.text = ""
            confermPassTF.text = ""
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
