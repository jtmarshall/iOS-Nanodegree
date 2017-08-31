//
//  HudNode.swift
//  pushGame
//
//  Created by Jordan  on 8/4/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class HudNode: SKNode {
    private let scoreKey = "FLOOP_HIGHSCORE"
    private let lastScore = "FLOOP_LASTSCORE"
    private let scoreNode = SKLabelNode(fontNamed: "MarkerFelt-Thin")
    private(set) var score : Int = 0
    private var highScore : Int = 0
    private var showingHighScore = false
    
    // Setup top HUD.
    public func setup(size: CGSize) {
        let defaults = UserDefaults.standard
        
        highScore = defaults.integer(forKey: scoreKey)
        
        scoreNode.text = "\(score)"
        scoreNode.fontSize = 70
        scoreNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreNode.zPosition = 1
        
        addChild(scoreNode)
    }
    
    /*
     Add point, increment score.
     Saves to Core Data.
     If high score, enlarge scoreNode and update the color.
    */
    public func addPoint() {
        score += 1
        updateScoreboard()
        
        if score > highScore {
            /* 
             Saving new highscore in Core Data.
             So here we are retching records of "HighScoreEntity",
             then checking if the first item exists (should be the only item),
             if it does then we update the value with the new highscore.
             Else, we create a new entity object with the name of "highscore" and the score value.
             */
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
                        list.setValue(score, forKey: "value")
                        print("New highscore saved.")
                    }
                } else {
                    print("Error saving score.")
                }
            // If no previous highscore create new
            } else {
                let newScore = NSEntityDescription.insertNewObject(forEntityName: "HighScoreEntity", into: context)
                newScore.setValue("highscore", forKey: "name")
                newScore.setValue(score, forKey: "value")
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
            
            let defaults = UserDefaults.standard
            defaults.set(score, forKey: scoreKey)
            
            if !showingHighScore {
                showingHighScore = true
                
                scoreNode.run(SKAction.scale(to: 1.5, duration: 0.25))
                scoreNode.fontColor = SKColor(red:0.99, green:0.92, blue:0.55, alpha:1.0)
            }
        }
    }
    
    // Delete Old Core Data, (used this originally to delete and create new; now just here for reference)
//    func deleteAllRecords() {
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        let context = delegate.persistentContainer.viewContext
//        
//        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "HighScoreEntity")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//        
//        do {
//            try context.execute(deleteRequest)
//            try context.save()
//        } catch {
//            print ("There was an error")
//        }
//    }
    
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
    
    // Create Record (for reference)
    private func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject?
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        
        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        return result
    }
    
    /*
     Reset points.
     Sets score to zero.
     Updates score label.
     Resets color and size to default values.
     */
    public func resetPoints() {
        score = 0
        
        updateScoreboard()
        
        if showingHighScore {
            showingHighScore = false
            
            scoreNode.run(SKAction.scale(to: 1.0, duration: 0.25))
            scoreNode.fontColor = SKColor.white
        }
    }
    
    public func saveLastScore() {
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: lastScore)
    }
    
    // Updates the score label to show the current score.
    private func updateScoreboard() {
        scoreNode.text = "\(score)"
    }
}
