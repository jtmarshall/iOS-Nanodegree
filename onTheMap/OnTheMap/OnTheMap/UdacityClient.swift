//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    var session = URLSession.shared
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: String? = nil
    
    override init() {
        super.init()
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}
