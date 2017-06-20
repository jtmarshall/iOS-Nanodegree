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
    // Session
    var session = URLSession.shared
    
    // Auth state
    var accountId: String? = nil
    var accountRegistered: Bool? = nil
    var sessionId: String? = nil
    var sessionExpiration: String? = nil
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    func postSessionWithUdAPI(completionHandlerForPostWithUdAPI: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(StudentInfo.LoginData.username)\", \"password\": \"\(StudentInfo.LoginData.password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count))
            let newData = data?.subdata(in: range) /* subset response data! */
            //print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertData: completionHandlerForPostWithUdAPI)
            
        }
        task.resume()
        return task
    }
    
    func getPublicUserData(userId: String?, completionHandlerForPublicUserData: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let userId = userId!
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userId)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count))
            let newData = data?.subdata(in: range) /* subset response data! */
            //print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertData: completionHandlerForPublicUserData)
        }
        task.resume()
        return task
    }
    
    func deleteASession(completionHandlerForDeleteSession: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count))
            let newData = data?.subdata(in: range) /* subset response data! */
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertData: completionHandlerForDeleteSession)
        }
        task.resume()
        return task
    }
    
    func postAStudentLocation(newUniqueKey: String, newFirstName: String, newLastName: String, newAddress: String, newLat: String, newLon: String, mediaURL: String, _ completionHandlerForPostAStudentLocation: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(newUniqueKey)\", \"firstName\": \"\(newFirstName)\", \"lastName\": \"\(newLastName)\",\"mapString\": \"\(newAddress)\", \"mediaURL\": \"https://\(mediaURL)\",\"latitude\": \(newLat), \"longitude\": \(newLon)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                completionHandlerForPostAStudentLocation(false, "post failed 1.")
                return
            }
            let parsedResult: [String:AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForPostAStudentLocation(false, "Could not parse the data as JSON: \(String(describing: data)).")
                return
            }
            
            guard let objectId = parsedResult["objectId"] as? String else {
                completionHandlerForPostAStudentLocation(false, "There is no objectId.")
                return
            }
            StudentInfo.NewStudent.objectID = objectId
            completionHandlerForPostAStudentLocation(true, nil)
            
        }
        task.resume()
        
    }
    
    // Get locations for students
    func getMultipleStudentLocationsMethod(completionHandlerForMultipleStudentLocations: @escaping (_ success: Bool, _ locationJSON: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: StudentInfo.StudentLocation.studentLocationURL)!)
        request.addValue(StudentInfo.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfo.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("Error with POST request: \(String(describing: error))")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Status code doesn't conform to 2xx.")
                return
            }
            guard let data = data else {
                print("Request returned no data.")
                return
            }
            
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Couldn't parse data as JSON: \(data)")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                print("No results found.")
                return
            }
            
            StudentInfo.StudentData.studentInformation = results
            DispatchQueue.main.async {
                completionHandlerForMultipleStudentLocations(true, StudentInfo.StudentData.studentInformation, nil)
            }
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }

    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
