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
    
    static var firstName = ""
    static var lastName = ""
    static var location = ""
    static var website = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(dictionary: [String:AnyObject]) {
        if let fName = dictionary[StudentLocation.firstName] as? String {
            StudentInfo.firstName = fName
        }
        if let lName = dictionary[StudentLocation.lastName] as? String {
            StudentInfo.lastName = lName
        }
        if let mapString = dictionary[StudentLocation.mapString] as? String {
            StudentInfo.location = mapString
        }
        if let mediaURL = dictionary[StudentLocation.mediaURL] as? String {
            StudentInfo.website = mediaURL
        }
    }
    
    static func StudentInformation(_ results: [[String:AnyObject]]) -> [StudentInfo] {
        var studentDictionary = [StudentInfo]()
        
        for result in results {
            studentDictionary.append(StudentInfo(dictionary: result))
        }
        return studentDictionary
    }
    
    // UdacityClient
    struct LoginData {
        static var username = ""
        static var password = ""
    }
    
    // Student Info
    struct StudentData {
        //static var studentInformation = [[String:AnyObject]]()
        let students = [StudentInfo]()
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
