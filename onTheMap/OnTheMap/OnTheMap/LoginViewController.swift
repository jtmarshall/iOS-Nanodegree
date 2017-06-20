//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 5/31/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // Outlets
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.Password.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //unsubscribeFromAllNotifications()
    }
    
    // Login
    @IBAction func loginPress(_ sender: AnyObject) {
        userDidTapView(self)
        if Username.text!.isEmpty || Password.text!.isEmpty {
            print("Username or Password Empty.")
        } else {
            StudentInfo.LoginData.username = Username.text!
            StudentInfo.LoginData.password = Password.text!
            setUIEnabled(false)
            UdacityClient.sharedInstance().authenticateWithViewController(self) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.displayError(errorString)
                    }
                }
            }
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
            self.present(controller, animated: true, completion: nil)
        }
    }
}

// UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(Username)
        resignIfFirstResponder(Password)
    }
}

extension LoginViewController {
    
    // Popup if Login error
    func displayError(_ errorString: String?) {
        if let errorString = errorString {
            let popAlert = UIAlertController(title: "Error!", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
            popAlert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                popAlert.dismiss(animated: true, completion: nil)
            })
            self.present(popAlert, animated: true)
        }
    }
    
    func setUIEnabled(_ enabled: Bool) {
        Username.isEnabled = enabled
        Password.isEnabled = enabled
        LoginButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            LoginButton.alpha = 1.0
        } else {
            LoginButton.alpha = 0.5
        }
    }
}
