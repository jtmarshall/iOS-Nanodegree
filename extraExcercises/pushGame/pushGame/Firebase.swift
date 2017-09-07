//
//  Firebase.swift
//  pushGame
//
//  Created by Jordan  on 9/6/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import Firebase

class FirebaseShare {
    
    // Push updated String score to Firebase DB
    func updateScore(score: Int, dbRef: DatabaseReference, uname: String, completion: @escaping(Any)->Void) {
        
        var success = " "
        var strg = " "
        // Create string with input score
        if (uname.characters.count > 0) {
            // If the give name
            strg = "Firebase DB Score: \(score) by \(uname)"
        } else {
            // If not
            strg = "Firebase DB Score: \(score)"
        }
        // Push string with score up to DB that has key "highscore"
        //dbRef.setValue(strg)
        dbRef.setValue(strg, withCompletionBlock: { (error, _) in
            if error != nil {
                print("Failed to set value")
                success = "Failed to sync high score. Check network/permissions."
            } else {
                success = "Successfully synced high score."
            }
            // Return the proper text on completion
            completion(success)
        })
    }
    
    class func sharedInstance() -> FirebaseShare {
        struct Singleton {
            static var sharedInstance = FirebaseShare()
        }
        return Singleton.sharedInstance
    }
}
