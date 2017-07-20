//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Jordan  on 7/10/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    // Pass in the query string parameters
    func taskForGETMethod(parameters: String?, completionHandlerForGET: @escaping (_ deserializedData: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Build the URL, Configure the request
        let urlString = Flickr.APIScheme + Flickr.APIHost + Flickr.APIPath + parameters!
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // Error sending request
            guard (error == nil) else {
                sendError(error: "Error with your request: \(String(describing: error?.localizedDescription))")
                return
            }
            
            // Receive successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Request returned status code other than 2xx.")
                return
            }
            
            // Error, no data returned
            guard let data = data else {
                sendError(error: "No data returned by request.")
                return
            }
            
            // Parse raw JSON and pass values to completion handler
            self.parseJSONCompletionHandler(data, completionHandlerForParsingJSON: completionHandlerForGET)
        }
        
        // Start request
        task.resume()
        
        return task
    }
    
    // Deserialize json and cast into useable object (AnyObject)
    private func parseJSONCompletionHandler(_ data: Data, completionHandlerForParsingJSON: (_ deserializedData: AnyObject?, _ error: NSError?) -> Void) {
        
        var deserializedData: AnyObject! = nil
        do {
            deserializedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Can't parse data as JSON: '\(data)'"]
            // If there's an error, the completion handler is passed the arguments below.
            completionHandlerForParsingJSON(nil, NSError(domain: "parseJSONCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        // If there's no error, the completion handler is passed the arguments below, taskForGETMethod
        completionHandlerForParsingJSON(deserializedData, nil)
    }

    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}

extension FlickrClient {
    
    // HTTP photos response returns dictionary
    func getLocationPhotos(latitude: Double, longitude: Double, pageNumber: Int, completionHandlerForPhotos: @escaping (_ success: Bool, _ urlArray: [String]?, _ error: NSError?) -> Void) {
        
        let latString = String(describing: latitude)
        let lonString = String(describing: longitude)
        
        // Query string parameters pass in to task
        let parameters = FlickrParameterKeys.Method + FlickrParameterValues.SearchMethod + "&" + FlickrParameterKeys.APIKey + FlickrParameterValues.APIKey + "&" + FlickrParameterKeys.Latitude + latString + "&" + FlickrParameterKeys.Longitude + lonString + "&" + FlickrParameterKeys.Extras + FlickrParameterValues.MediumURL + "&" + FlickrParameterKeys.Format + FlickrParameterValues.ResponseFormat + "&" + FlickrParameterKeys.NoJSONCallback + FlickrParameterValues.DisableJSONCallback + "&" + FlickrParameterKeys.PerPage + FlickrParameterValues.PerPage + "&" + FlickrParameterKeys.Page + "\(pageNumber)"
        
        taskForGETMethod(parameters: parameters) { (deserializedData, error) in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPhotos(false, nil, NSError(domain: "completionHandlerForGET", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "Error with request: \(error?.localizedDescription ?? "Error")")
                return
            }
            
            guard (deserializedData != nil) else {
                sendError(error: "No results found.")
                return
            }
            
            // If Flickr returns an error
            guard let stat = deserializedData?[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                sendError(error: "Flickr API returned error: \(deserializedData ?? "Error" as AnyObject)")
                return
            }
            
            // Check for "photos" and "photo" keys in our result
            guard let photosContainer = deserializedData?[FlickrResponseKeys.Photos] as? [String:AnyObject], let photosArray = photosContainer[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError(error: "Can't find keys '\(FlickrResponseKeys.Photos)' and '\(FlickrResponseKeys.Photo)' in \(deserializedData ?? "Error" as AnyObject)")
                return
            }
            
            var urlArray = [String]()
            
            for photo in photosArray {
                guard let url = photo[FlickrResponseKeys.MediumURL] as? String else {
                    sendError(error: "Can't find url")
                    return
                }
                
                urlArray.append(url)
            }
            
            // Retrieve urlArray rather than images themselves, because resources...
            completionHandlerForPhotos(true, urlArray, nil)
        }
    }
    
    // Get pages of photos for location, return a random page number in that range on refresh
    func getNumberOfPages(latitude: Double, longitude: Double, completionHandlerForPhotos: @escaping (_ success: Bool, _ numberOfPagesInt: Int?, _ error: NSError?) -> Void) {
        
        let latString = String(describing: latitude)
        let lonString = String(describing: longitude)
        
        // Query string parameters pass in to task
        let parameters = FlickrParameterKeys.Method + FlickrParameterValues.SearchMethod + "&" + FlickrParameterKeys.APIKey + FlickrParameterValues.APIKey + "&" + FlickrParameterKeys.Latitude + latString + "&" + FlickrParameterKeys.Longitude + lonString + "&" + FlickrParameterKeys.Extras + FlickrParameterValues.MediumURL + "&" + FlickrParameterKeys.Format + FlickrParameterValues.ResponseFormat + "&" + FlickrParameterKeys.NoJSONCallback + FlickrParameterValues.DisableJSONCallback + "&" + FlickrParameterKeys.PerPage + FlickrParameterValues.PerPage
        
        // This IS Used and xcode is dumb
        taskForGETMethod(parameters: parameters) { (deserializedData, error) in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPhotos(false, nil, NSError(domain: "completionHandlerForGET", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "Error with request: \(error?.localizedDescription ?? (error as AnyObject) as! String)")
                return
            }
            
            guard (deserializedData != nil) else {
                sendError(error: "No results found.")
                return
            }
            
            // If Flickr returns an error
            guard let stat = deserializedData?[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                sendError(error: "Flickr API returned error: \(deserializedData ?? (error as AnyObject))")
                return
            }
            
            // Check for "photos" and "photo" keys in our result
            guard let photosContainer = deserializedData?[FlickrResponseKeys.Photos] as? [String:AnyObject], let photosArray = photosContainer[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError(error: "Can't find keys '\(FlickrResponseKeys.Photos)' and '\(FlickrResponseKeys.Photo)' in \(deserializedData ?? error as AnyObject)")
                return
            }
            
            // Check for page keys
            guard let numberOfPagesInt = photosContainer[FlickrResponseKeys.Pages] as? Int else {
                sendError(error: "Can't find key '\(FlickrResponseKeys.Pages)' in \(deserializedData ?? error as AnyObject)")
                return
            }
            print("#ofPages: ", numberOfPagesInt)
            var urlArray = [String]()
            
            for photo in photosArray {
                guard let url = photo[FlickrResponseKeys.MediumURL] as? String else {
                    sendError(error: "Can't find url")
                    return
                }
                
                urlArray.append(url)
            }
            
            // Retrieve urlArray rather than images themselves, because resources...
            completionHandlerForPhotos(true, numberOfPagesInt, nil)
        }
    }
    
    // Helper: given URL get UIImage to load in collection view cell
    func downloadPhotoWith(url: String, completionHandlerForDownload: @escaping (_ success: Bool, _ imageData: NSData?, _ error: Error?) -> Void) {
        
        let session = URLSession.shared
        // Convert url string to URL to be passed into dataTask
        let photoURL = URL(string: url)
        
        let task = session.dataTask(with: photoURL!) { (data, response, error) in
            guard let imageData = data else {
                completionHandlerForDownload(false, nil, error)
                return
            }
            
            completionHandlerForDownload(true, imageData as NSData?, nil)
        }
        
        task.resume()
    }
}
