//
//  constants.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

struct StudentInformation {
    
    var firstName = ""
    var lastName = ""
    var location = ""
    var website = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(dictionary: [String:AnyObject]) {
        if let fName = dictionary[StudentLocation.firstName] as? String {
            firstName = fName
        }
        if let lName = dictionary[StudentLocation.lastName] as? String {
            lastName = lName
        }
        if let mapString = dictionary[StudentLocation.mapString] as? String {
            location = mapString
        }
        if let mediaURL = dictionary[StudentLocation.mediaURL] as? String {
            website = mediaURL
        }
    }
    
    // UdacityClient
    struct UdacityClient {
        static var username = ""
        static var password = ""
    }
    
    // Student Info
    struct StudentData {
        static var studentInformation = [[String:AnyObject]]()
        static var objectId = ""
    }
    
    struct student {
        static var studentInformation = [[String:AnyObject]]()
        static var objectId = ""
    }
    
    struct StudentLocation {
        static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let studentLocationURL = "https://parse.udacity.com/parse/classes/StudentLocation"
        static var objectID = "objectID"
        static var uniqueKey = "uniqueKey"
        static var firstName = "firstName"
        static var lastName = "lastName"
        static var mapString = "mapString"
        static var mediaURL = "mediaURL"
        static var latitude: Double = 0
        static var longitute: Double = 0
    }
    
    // New
    struct NewStudent {
        static var address = ""
        static var uniqueKey = ""
        static var firstName = "firstName"
        static var lastName = "lastName"
        static var mediaURL = "mediaURL"
        static var objectID = "objectID"
    }

}
