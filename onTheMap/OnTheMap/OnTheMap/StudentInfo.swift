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
    
    // UdacityClient
    struct UdacityClient {
        static var username = ""
        static var password = ""
    }
    
    // Student Info
    struct student {
        static var studentInformation = [[String:AnyObject]]()
        static var objectId = ""
    }
    
    // UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    // New
    struct newStudent {
        static var address = ""
        static var uniqueKey = ""
    }
}
