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
    func updateScore(score: Int, dbRef: DatabaseReference, uname: String) -> Bool {
        
        var strg = " "
        // Create string with input score
        if (uname != nil) {
            // If the give name
            strg = "Firebase DB Score: \(score) by \(uname)"
        } else {
            // If not
            strg = "Firebase DB Score: \(score)"
        }
        // Push string with score up to DB that has key "highscore"
        dbRef.setValue(strg)
        return true
    }
    
    class func sharedInstance() -> FirebaseShare {
        struct Singleton {
            static var sharedInstance = FirebaseShare()
        }
        return Singleton.sharedInstance
    }
}
