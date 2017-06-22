//
//  Convenience.swift
//  OnTheMap
//
//  Created by Jordan  on 6/16/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    func authenticateWithViewController(_ hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getUserId() {(success, userId, errorString) in
            if success {
                if let userId = userId {
                    self.getUserData(userId: userId) { (success, userData, errorString) in
                        completionHandlerForAuth(success, errorString)
                    }
                } else {
                    completionHandlerForAuth(success, errorString)
                }
            } else {
                completionHandlerForAuth(success, errorString)
            }
        }
        
    }
    
    func deleteViewController(completionHandlerForDelete: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getDeleteSessionID() { (success, userId, errorString) in
            
            completionHandlerForDelete(success, errorString)
        }
        
    }
    
    private func getUserId(_ completionHandlerForUserID: @escaping (_ success: Bool, _ userID: String?, _ errorString: String?) -> Void) {
        let _ = postSessionWithUdAPI() { (result, error) in
            
            if error != nil {
                completionHandlerForUserID(false, nil, "Couldn't connect to the Internet.")
            } else {
                if let account = result?["account"] as? [String:AnyObject] {
                    if let userId = account["key"] as? String {
                        StudentInfo.NewStudent.uniqueKey = userId
                        completionHandlerForUserID(true, userId, nil)
                    } else {
                        completionHandlerForUserID(false, nil, "The credentials were incorrect, please try again")
                    }
                } else {
                    completionHandlerForUserID(false, nil, "The credentials were incorrect, please try again")
                }
            }
        }
    }
    
    private func getUserData(userId: String?, _ completionHandlerForUserData: @escaping (_ success: Bool, _ userData: [String:AnyObject]?, _ errorString: String?) -> Void) {
        
        let userId = userId!
        let _ = getPublicUserData(userId: userId) { (result, error) in
            if let error = error {
                print (error)
                completionHandlerForUserData(false, nil, "Fail to get userData")
            } else {
                let userResult = result!
                if let userData = userResult["user"] as? [String:AnyObject] {
                    if let lastName = userData["last_name"] as? String, let firstName = userData["first_name"] as? String {
                        StudentInfo.NewStudent.firstName = firstName
                        StudentInfo.NewStudent.lastName = lastName
                    }
                    completionHandlerForUserData(true, userData, nil)
                } else {
                    print ("Could not find userData")
                }
            }
        }
    }
    
    private func getDeleteSessionID(_ completionHandlerForDeleteSessionID: @escaping (_ success: Bool, _ DeleteSessionID: String?, _ errorString: String?) -> Void) {
        
        let _ = deleteASession(){ (result, error) in
            if let error = error {
                print ("error is \(error)")
                completionHandlerForDeleteSessionID(false, nil, "Fail to get deleteSessionID")
            } else {
                if let deleteResult = result {
                    if let deleteSession = deleteResult["session"] as? [String:AnyObject] {
                        if let deleteSessionID = deleteSession["id"] as? String {
                            print ("deleteSessionID is \(deleteSessionID)")
                            completionHandlerForDeleteSessionID(true, deleteSessionID, nil)
                        } else {
                            completionHandlerForDeleteSessionID(false, nil, "Fail to get deleteSessionID")
                        }
                    } else {
                        completionHandlerForDeleteSessionID(false, nil, "Fail to get deleteSession")
                    }
                } else {
                    completionHandlerForDeleteSessionID(false, nil, "Fail to get deleteResult")
                }
            }
        }
        
    }
}
