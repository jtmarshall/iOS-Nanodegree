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
    
    // Initializers
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
                completionHandlerForPostWithUdAPI(request as AnyObject, error! as NSError)
            }
            let range = Range(uncheckedBounds: (5, data!.count))
            let newData = data?.subdata(in: range) /* subset response data! */
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
    
    func postAStudentLocation(newUniqueKey: String, newFirstName: String, newLastName: String, newAddress: String, newLat: String, newLon: String, mediaURL: String, _ completion: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(newUniqueKey)\", \"firstName\": \"\(newFirstName)\", \"lastName\": \"\(newLastName)\",\"mapString\": \"\(newAddress)\", \"mediaURL\": \"https://\(mediaURL)\",\"latitude\": \(newLat), \"longitude\": \(newLon)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                completion(false, "Failed Post")
                self.showError(errorString: "Failed Post")
                return
            }
            let parsedResult: [String:AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completion(false, "Could not parse the data as JSON: \(String(describing: data)).")
                self.showError(errorString: "Couldn't Parse JSON")
                return
            }
            
            guard let objectId = parsedResult["objectId"] as? String else {
                completion(false, "There is no objectId.")
                self.showError(errorString: "No ObjectID")
                return
            }
            StudentInfo.NewStudent.objectID = objectId
            completion(true, nil)
        }
        task.resume()
        
    }
    
    // Get locations for students
    func getStudentLocations(completion: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: StudentInfo.StudentLocation.studentLocationURL)!)
        request.addValue(StudentInfo.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfo.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            // Added pop alerts for each fail point
            guard (error == nil) else {
                let er = "Error with POST request"
                self.showError(errorString: er)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let er = "Status code doesn't conform to 2xx."
                self.showError(errorString: er)
                return
            }
            guard let data = data else {
                let er = "Request returned no data."
                self.showError(errorString: er)
                return
            }
            
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                let er = "Couldn't parse data as JSON"
                self.showError(errorString: er)
                return
            }
            
            // Redo for the struct version of StudentInfo
            if let resultsArray = parsedResult["results"] {
                StudentInfo.StudentData.students.removeAll()
                
                var results = [[String:AnyObject]]()
                results = resultsArray as! [[String : AnyObject]]
                
                for result in results {
                    var dictionary = [String:AnyObject]()
                    
                    dictionary["firstName"] = result["firstName"]
                    dictionary["lastName"] = result["lastName"]
                    dictionary["latitude"] = result["latitude"]
                    dictionary["longitude"] = result["longitude"]
                    dictionary["mapString"] = result["mapString"]
                    dictionary["mediaURL"] = result["mediaURL"]
                    dictionary["objectId"] = result["objectId"]
                    dictionary["uniqueKey"] = result["uniqueKey"]
                    
                    let student = StudentInfo(dictionary: dictionary)
                    StudentInfo.StudentData.students.append(student)
                }
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        }
        task.resume()
    }
    
    // POST
    func POSTMethodParse(newUniqueKey: String, newMapString: String, newMediaURL: String, newLatitude: String, newLongitude: String) {
        
        let request = NSMutableURLRequest(url: URL(string: StudentInfo.StudentLocation.studentLocationURL)!)
        request.httpMethod = "POST"
        request.addValue(StudentInfo.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfo.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(newUniqueKey)\", \"firstName\": \"\(StudentInfo.NewStudent.firstName)\", \"lastName\": \"\(StudentInfo.NewStudent.lastName)\",\"mapString\": \"\(newMapString)\", \"mediaURL\": \"\(newMediaURL)\",\"latitude\": \(newLatitude), \"longitude\": \(newLongitude)}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                let er = "Error with POST request"
                self.showError(errorString: er)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let er = "Status code doesn't conform to 2xx."
                self.showError(errorString: er)
                return
            }
            
            guard let data = data else {
                let er = "Request returned no data."
                self.showError(errorString: er)
                return
            }
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            
            var parsedResult: [String:AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                let er = "Couldn't parse data as JSON"
                self.showError(errorString: er)
                return
            }
            
            guard let objectID = parsedResult["objectID"] as? String else {
                let er = "No objectId"
                self.showError(errorString: er)
                return
            }
            
            StudentInfo.NewStudent.objectID = objectID
        }
        task.resume()
    }
    
    // Popup alert
    func showError(errorString: String) {
        let popAlert = UIAlertController(title: "Error!", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        popAlert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            popAlert.dismiss(animated: true, completion: nil)
        })
        UIApplication.shared.keyWindow?.rootViewController?.present(popAlert, animated: true, completion: nil)
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
