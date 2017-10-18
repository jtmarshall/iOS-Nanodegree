////
////  Facebook.swift
////  pushGame
////
////  Created by Jordan  on 8/31/17.
////  Copyright © 2017 Jordan . All rights reserved.
////
//
//import Foundation
//import UIKit
//import Social
//
//class FacebookShare {
//    
//    func shareScore(score: Int) -> UIAlertController {
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
//                post.setInitialText("Floop Highscore \(score)")
//                post.add(UIImage(named: "yellow_ball"))
//                
//                //self.present(post, animated: true, completion: nil)
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.window?.rootViewController?.present(post, animated: true, completion: nil)
//            } else {
//                // If can't connect show alert
//                //self.showAlert(service: "Facebook")
//                let alertView = UIAlertView()
//                alertView.addButton(withTitle: "Dismiss")
//                alertView.title = "Error"
//                alertView.message = "You are not connected to Facebook."
//                alertView.show()
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
//        //self.present(alert, animated: true, completion: nil)
//        return alert
//    }
//    
////    func showAlert(service: String){
////        // Create alert and anction
////        let alert = UIAlertController(title: "Error", message: "You are not connected to \(service)", preferredStyle: .alert)
////        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
////        
////        // Add action then present alert
////        alert.addAction(action)
////        
////        present(alert, animated: true, completion: nil)
////    }
//    
//    class func sharedInstance() -> FacebookShare {
//        struct Singleton {
//            static var sharedInstance = FacebookShare()
//        }
//        return Singleton.sharedInstance
//    }
//
//}
