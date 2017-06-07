//
//  ViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 5/31/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
            alertAction() }
        UdacityClient.sharedInstance().loginToUdacity(username: (emailTextField.text)!, password: (passwordTextField.text)!, completionHandlerForLogin: {(
            success, result, error) in
            if success {
                self.toMapView()
                self.completeLogin()
                
            }
            
        }
        )}
    
    
    func alertAction() {
        let alertController = UIAlertController(title: "Error", message: "Empty username or password", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func completeLogin() {
        print("Yeah")
    }
    
    func displayError() {
        print("Error")
    }
    
    func toMapView() {
        let controller: MapViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "Map") as! MapViewController
        print("Hiiiii")
        present(controller, animated: true, completion: nil)
    }
    
}
