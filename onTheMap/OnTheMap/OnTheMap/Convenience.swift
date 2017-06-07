//
//  Convenience.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func loginToUdacity(username: String, password: String, completionHandlerForLogin: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.urlUdacity.sessionURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                print("Error with POST request")
                return
                
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Request returned a status code other than 2xx")
                return
            }
            
            guard let data = data else {
                print("No data returned from request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForLogin)
        }
        
        task.resume()
        
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse as JSON: \(data)"]
            completionHandlerForConvertData(false, nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        guard let account = parsedResult["account"] as? [String:AnyObject] else {
            print("Error with account information.")
            return
        }
        
        guard (account["key"] as? String) != nil else {
            print("Error with user ID.")
            return
        }
        
        guard let sessionDictionary = parsedResult["session"] as? [String:AnyObject] else {
            print("Error with session dictionary.")
            return
        }
        
        guard (sessionDictionary["userID"] as? String) != nil else {
            print("Error with session ID.")
            return
        }
        
        completionHandlerForConvertData(true, parsedResult, nil)
        
    }
    
}
