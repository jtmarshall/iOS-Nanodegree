//
//  constants.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation

struct Constants  {
    
    struct urlUdacity {
        static let baseURL = "https://www.udacity.com/api"
        static let sessionURL = "https://www.udacity.com/api/session"
        static let userURL = "https://www.udacity.com/api/users"
    }
    
    struct ParameterKeys {
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
        static let sessionID = "session"
    }
    
    struct JSONResponseKeys {
        static let userID = "userID"
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let account = "account"
        static let session = "session"
        static let accountKey = "key"
        static let expiration = "expiration"
    }
    
}
