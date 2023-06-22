//
//  ViewController.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var resendEmailBtn: UIButton!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupBackgroundTapped()
        
        emailTF.delegate = self
        passwordTF.delegate = self
        
        emailTF.text = testEmail
        passwordTF.text = testEmailPassword
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgetPasswordClicked(_ sender: Any) {
        emailTF.text != "" ? forgetPassword() : ProgressHUD.showError("Email is required")
    }
    
    @IBAction func resendEmailCliced(_ sender: Any) {
        emailTF.text != "" ? resendVerificationEmail() : ProgressHUD.showError("Email is required")
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        checkData() ? loginUser() : ProgressHUD.showError("All Fields are required")
    }
    
    
    
    // MARK: - Helper
    private func checkData() -> Bool {
        return emailTF.text != "" && passwordTF.text != ""
    }
    
    private func setupBackgroundTapped(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard(){
        view.endEditing(false)
    }

    
    // MARK: - loginUser
    private func loginUser(){
        FUserListener.shared.loginUserWith(email: emailTF.text!, password: passwordTF.text!) { error, isEmailVerified in
            guard error == nil else {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            guard isEmailVerified else {
                ProgressHUD.showFailed("Please verify your email")
                return
            }
            self.goToApp()
        }
    }
    
    // MARK: - resendVerificationEmail
    func resendVerificationEmail(){
        FUserListener.shared.resendLinkVerification(email: emailTF.text!) { error in
            guard error == nil else {
                ProgressHUD.showFailed(error!.localizedDescription)
                return
            }
            ProgressHUD.showSucceed("Verification email send")
        }
    }
    
    // MARK: - forgetPassword
    func forgetPassword(){
        FUserListener.shared.resetPassword(email: emailTF.text!) { error in
            guard error == nil else {
                ProgressHUD.showFailed(error!.localizedDescription)
                return
            }
            ProgressHUD.showSucceed("Reset password email has been sent")
        }
    }
    
    // MARK: - Navigation
    private func goToApp(){
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true)
    }
    
}

// MARK: - UIText Delegate
extension LoginViewController : UITextFieldDelegate {
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            ProgressHUD.showError("All Fields must not have space")
            return false
        }
        return true
    }
    
}
