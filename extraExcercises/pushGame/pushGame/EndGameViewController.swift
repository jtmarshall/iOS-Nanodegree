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
import FBSDKLoginKit
import Social
import CoreData

class EndGameViewController: UIViewController {
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var resetScoreButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var gameOverText: UILabel!
    @IBOutlet weak var highScoreNode: UILabel!
    @IBOutlet weak var recentScoreNode: UILabel!
    
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
    
    // When Share button is hit
    @IBAction func shareAction(_ sender: Any) {
        // Call Facebook share function
        let alert = FacebookShare.sharedInstance().shareScore(score: score)
        self.present(alert, animated: true, completion: nil)
        
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
        // Create alert and anction
        let alert = UIAlertController(title: "Error", message: "You are not connected to \(service)", preferredStyle: .alert)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
