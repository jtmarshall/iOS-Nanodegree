//
//  EndGameViewController.swift
//  pushGame
//
//  Created by Jordan  on 8/29/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit
//import FBSDKLoginKit
import Social
import CoreData
import Firebase
import FirebaseDatabase

class EndGameViewController: UIViewController {
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var resetScoreButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var gameOverText: UILabel!
    @IBOutlet weak var highScoreNode: UILabel!
    @IBOutlet weak var recentScoreNode: UILabel!
    // Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    // Firebase label
    @IBOutlet weak var conditionLabel: UILabel!
    // 2nd UIControl for Highscore Name Input
    @IBOutlet weak var usernameText: UITextField!
    // Firebase reference
    let rootRef = Database.database().reference().child("highscore")
    // Keyboard ref
    var keyboardOnScreen = false
    
    private let scoreKey = "FLOOP_HIGHSCORE"
    private let lastScore = "FLOOP_LASTSCORE"
    var score = 0
    var recentScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Most recent score
        let defaults = UserDefaults.standard
        recentScore = defaults.integer(forKey: lastScore)
        recentScoreNode.text = "Last Score: \(recentScore)"
        
        // Keyboard notifications
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
        
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
                    score = highScore
                    break
                }
            }
            // If we can't fetch a highscore just set it to 0
        } catch {
            print("Unable to fetch managed objects for entity")
            highScoreNode.text = "High Score: 0"
        }
    }
    
    // For Firebase
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Watches the value in Firebase DB with key "highscore" and updates UILabel accordingly
        rootRef.observe(.value) { (snap: DataSnapshot) in
            self.conditionLabel.text = (snap.value as AnyObject).description
        }
    }
    
    // When Reset Score button hit
    @IBAction func resetScore(_ sender: Any) {
        // Overwrite high score with 0
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: scoreKey)
        
        // Start overwrite Core Data highscore
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var list: NSManagedObject? = nil
        let lists = fetchRecordsForEntity("HighScoreEntity", inManagedObjectContext: context)
        print(lists)
        // Check if previous highscore exists
        if let listRecord = lists.first {
            list = listRecord
            if let list = list {
                // Find highscore entity
                if (list.value(forKey: "name") as? String == "highscore") {
                    // Update new score value to "highscore" entity
                    list.setValue(0, forKey: "value")
                    print("New highscore saved.")
                }
            } else {
                print("Error saving score.")
            }
            // If no previous highscore create new
        } else {
            let newScore = NSEntityDescription.insertNewObject(forEntityName: "HighScoreEntity", into: context)
            newScore.setValue("highscore", forKey: "name")
            newScore.setValue(0, forKey: "value")
            print("Unable to fetch old score, new highscore created.")
        }
        
        // Try to Save
        do {
            try context.save()
            print("Score saved succesfully.")
        } catch {
            print("Error saving to core data.")
        }
        /* End Core Data Save */
        
        // Alert them
        let alertView = UIAlertView()
        alertView.addButton(withTitle: "Ok")
        alertView.title = "Oh Snap!"
        alertView.message = "You Reset Your Best Score!!!"
        alertView.show()
        // Update score text
        highScoreNode.text = "High Score: 0"
    }
    
    // Fetch Core data
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        return result
    }
    
    // When Share button is hit share to Firebase
    @IBAction func shareAction(_ sender: Any) {
        
        // Start up activity indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Update score function from firebase swift file passing in score and DB reference
        FirebaseShare.sharedInstance().updateScore(score: score, dbRef: rootRef, uname: usernameText.text!) { (response) in
            // Only show alert if sync failure
            if ((response as? String)!.characters.count > 0) {
                self.showAlert(service: (response as? String)!)
            }
            
            // Stop activity indicator after network process
            self.activityIndicator.stopAnimating()
        }
        
        // Tell user when score updated in Firebase
//        let alertView = UIAlertView()
//        alertView.addButton(withTitle: "Ok")
//        alertView.title = "Firebase"
//        alertView.message = FirebaseShare.sharedInstance().updateScore(score: score, dbRef: rootRef, uname: usernameText.text!)
//        alertView.show()
        
        // Call Facebook share function
        //let alert = FacebookShare.sharedInstance().shareScore(score: score)
        //self.present(alert, animated: true, completion: nil)
        
//        // Alert
//        let alert = UIAlertController(title: "Share", message: "Post Highscore?", preferredStyle: .actionSheet)
//        
//        // First action
//        let actionOne = UIAlertAction(title: "Share on Facebook", style: .default) { (action) in
//            
//            // Check if user connected to Facebook
//            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
//                let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
//                
//                post.setInitialText("Floop Highscore")
//                post.add(UIImage(named: "yellow_ball"))
//                
//                self.present(post, animated: true, completion: nil)
//            } else {
//                // If can't connect show alert
//                self.showAlert(service: "Facebook")
//            }
//        }
//        
//        // Allow for cancel share action
//        let actionTwo = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        // Add action to action sheet
//        alert.addAction(actionOne)
//        alert.addAction(actionTwo)
//        
//        // Present alert
//        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(service: String){
        // Create alert and action
        let alert = UIAlertController(title: "Firebase", message: service, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        // Add action then present alert
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Show GameScene when replay button is hit
    func handleReplayButtonClick() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let skView = self.view as! SKView
        let gameScene = GameScene()
        gameScene.scaleMode = .aspectFill
        skView.presentScene(gameScene, transition: transition)
    }
    
    // Keyboard view shifting
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
