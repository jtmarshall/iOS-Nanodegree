//
//  MenuViewController.swift
//  pushGame
//
//  Created by Jordan  on 8/4/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import FBSDKLoginKit
import CoreData

// Text strings
private struct TextString {
    static let shareSheetText = "Floop Highscore: "
    static let error = "Error"
    static let enableSocial = "Please sign in to your account first"
    static let settings = "Settings"
    static let ok = "OK"
}

class MenuViewController: UIViewController {
    // Start button from Storyboard
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var highScoreNode: UILabel!
    
    var high = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Core Data variables
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HighScoreEntity")
        // Try to get core data
        do {
            // Execute Fetch Request
            let records = try context.fetch(request)
            // Cycle through records (should only be one), and then set text to reflect highscore
            for result in (records as? [NSManagedObject])! {
                if result.value(forKey: "name") as? String == "highscore" {
                    let highScore = result.value(forKey: "value") as! Int
                    highScoreNode.text = "High Score: \(highScore)"
                    high = highScore
                    break
                }
            }
        // If we can't fetch a highscore just set it to 0
        } catch {
            print("Unable to fetch managed objects for entity")
            highScoreNode.text = "High Score: 0"
        }
        
        // Facebook Login
        let loginButton = FBSDKLoginButton()
        loginButton.setTitle("Login with Facebook", for: .normal)
        view.addSubview(loginButton)
        // Bottom center to display for login button
        loginButton.frame = CGRect(x: (view.frame.width / 2) - 100, y: view.frame.height - 140, width: 200, height: 40)
        
        //Set up start button
        startButton.setImage(UIImage(named: "button_start"), for: UIControlState.normal)

        //Set up sound button
        //soundButton.setImage(UIImage(named: "speaker_on"), for: UIControlState.normal)
    }
    
    // Call Facebook Logout
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of facebook")
    }
    
    // Call Facebook Login
    func loginButton(_ loginButtton: FBSDKLoginButton!, didCompleteWithresult: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with facebook!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
