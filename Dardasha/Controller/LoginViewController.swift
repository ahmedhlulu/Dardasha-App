//
//  ViewController.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var confermPassLbl: UILabel!
    @IBOutlet weak var haveAccountLbl: UILabel!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var haveAccountBtn: UIButton!
    @IBOutlet weak var resendEmailBtn: UIButton!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confermPassTF: UITextField!

    var isLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupOutlit(mode: isLogin)
        setupBackgroundTapped()
        emailTF.delegate = self
        passwordTF.delegate = self
        confermPassTF.delegate = self
        
        emailTF.text = "ahmadhlulu@gmail.com"
        passwordTF.text = "123456"
    }
    
    
    @IBAction func forgetPasswordClicked(_ sender: Any) {
        if isDataInputFor(mode: .forgetPassword){
            forgetPassword()
        }else{
            ProgressHUD.showError("Email is required")
        }
    }
    
    @IBAction func resendEmailCliced(_ sender: Any) {
        if isDataInputFor(mode: .forgetPassword){
            resendVerificationEmail()
        }else{
            ProgressHUD.showError("Email is required")
        }
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        if isDataInputFor(mode: isLogin ? .login : .register){
            
            isLogin ? loginUser() : registerUser()
        }else {
            ProgressHUD.showError("All Fields are required")
        }
    }
    
    @IBAction func haveAccountClicked(_ sender: Any) {
        setupOutlit(mode: isLogin)
    }
    
    func setupOutlit(mode: Bool){
        
        if !mode {
            // Login View
            titleLbl.text = "Login"
            confermPassLbl.isHidden = true
            confermPassTF.isHidden = true
            
            registerBtn.setTitle("Login", for: .normal)
            haveAccountBtn.setTitle("Register", for: .normal)
            haveAccountLbl.text = "New here?"
            
            resendEmailBtn.isHidden = true
            forgetPasswordBtn.isHidden = false
        }else {
            // Register View
            titleLbl.text = "Register"
            confermPassLbl.isHidden = false
            confermPassTF.isHidden = false
            
            registerBtn.setTitle("Register", for: .normal)
            haveAccountBtn.setTitle("Login", for: .normal)
            haveAccountLbl.text = "Have an account?"
            
            resendEmailBtn.isHidden = false
            forgetPasswordBtn.isHidden = true
        }
        isLogin.toggle()
        }
    
    // MARK: - Helper
    private enum LoginMode : String {
        case login
        case register
        case forgetPassword
    }
    
    private func isDataInputFor (mode: LoginMode) -> Bool {
        
        switch mode {
        case .login:
            return emailTF.text != "" && passwordTF.text != ""
        case .register:
            return emailTF.text != "" && passwordTF.text != "" && confermPassTF.text != ""
        case .forgetPassword:
            return emailTF.text != ""
        }
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
            FUserListener.shared.registerUserWith(email: emailTF.text!, password: passwordTF.text!) { error in
                guard error == nil else {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            }
            ProgressHUD.showSuccess("Varification email send, please check your email")
            passwordTF.text = ""
            confermPassTF.text = ""
            setupOutlit(mode: isLogin)
        }else {
            ProgressHUD.showError("Password is not same")
        }
    }
    
    // MARK: - loginUser
    private func loginUser(){
        FUserListener.shared.loginUserWith(email: emailTF.text!, password: passwordTF.text!) { error, isEmailVerified in
            if error == nil {
                if isEmailVerified {
                    // Success login
                    self.goToApp()
                }else {
                    ProgressHUD.showFailed("Please verify your email")
                }
            }else {
                ProgressHUD.showError(error!.localizedDescription)
            }
        }
    }
    
    // MARK: - resendVerificationEmail
    func resendVerificationEmail(){
        FUserListener.shared.resendLinkVerification(email: emailTF.text!) { error in
            if error == nil {
                ProgressHUD.showSucceed("Verification email send")
            }else{
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    // MARK: - forgetPassword
    func forgetPassword(){
        FUserListener.shared.resetPassword(email: emailTF.text!) { error in
            if error == nil {
                ProgressHUD.showSucceed("Reset password email has been sent")
            }else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        emailLbl.text = emailTF.hasText ? "Email" : " "
        passwordLbl.text = passwordTF.hasText ? "Password" : " "
        confermPassLbl.text = confermPassTF.hasText ? "Confirm Password" : " "
    }
}
