//
//  EmailVerificationViewController.swift
//  Dardasha
//
//  Created by Ahmed H Lulu on 26/06/2023.
//

import UIKit
import ProgressHUD

class EmailVerificationViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resendEmailCliced(_ sender: Any) {
        guard emailTF.text! != "" , passwordTF.text! != "" else {
            ProgressHUD.showError("Email and password is required")
            return
        }
        resendVerificationEmail()
    }
    
    // MARK: - resendVerificationEmail
    func resendVerificationEmail(){
        FUserListener.shared.loginUserWith(email: emailTF.text!, password: passwordTF.text!) { error, isEmailVerified in
            guard error == nil else {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            guard !isEmailVerified else {
                ProgressHUD.showError("Your email is verified")
                return
            }
            
            FUserListener.shared.resendLinkVerification() { error in
                guard error == nil else {
                    ProgressHUD.showFailed(error!)
                    return
                }
                ProgressHUD.showSucceed("Verification email send")
            }
        }
        
    }

}
