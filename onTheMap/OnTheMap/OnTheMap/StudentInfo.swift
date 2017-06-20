//
//  constants.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

struct StudentInfo {
    
    var firstName = ""
    var lastName = ""
    var latitude: Double?
    var longitude: Double?
    var mapString = ""
    var mediaURL = ""
    var objectId = ""
    var uniqueKey = ""
    
    init(dictionary: [String:AnyObject]) {
        self.firstName = (dictionary["firstName"] != nil) ? dictionary["firstName"] as! String : ""
        self.lastName = (dictionary["lastName"] != nil) ? dictionary["lastName"] as! String : ""
        self.latitude = (dictionary["latitude"] != nil) ? dictionary["latitude"] as? Double : nil
        self.longitude = (dictionary["longitude"] != nil) ? dictionary["longitude"] as? Double : nil
        self.mapString = (dictionary["mapString"] != nil) ? dictionary["mapString"] as! String : ""
        self.mediaURL = (dictionary["mediaURL"] != nil) ? dictionary["mediaURL"] as! String : ""
        self.objectId = (dictionary["objectId"] != nil) ? dictionary["objectId"] as! String : ""
        self.uniqueKey = (dictionary["uniqueKey"] != nil) ? dictionary["uniqueKey"] as! String : ""
    }
    
    // UdacityClient
    struct LoginData {
        static var username = ""
        static var password = ""
    }
    
    // Student Info
    struct StudentData {
        //static var studentInformation = [[String:AnyObject]]()
        static var students = [StudentInfo]()
        static var objectId = ""
    }
    
    // Student Location
    struct StudentLocation {
        static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let studentLocationURL = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt"
        static var objectID = "objectID"
        static var uniqueKey = "uniqueKey"
        static var firstName = "firstName"
        static var lastName = "lastName"
        static var mapString = "mapString"
        static var mediaURL = "mediaURL"
        static var latitude: Double = 0
        static var longitute: Double = 0
    }
    
    // To Post Data
    struct NewStudent {
        static var address = ""
        static var uniqueKey = ""
        static var firstName = ""
        static var lastName = ""
        static var mediaURL = ""
        static var objectID = ""
    }
}

class StudentDataSource {
    let studentData = [StudentInfo]()
    static let sharedInstance = StudentDataSource()
    private init() {} //This prevents others from using the default '()' initializer for this class.
}
