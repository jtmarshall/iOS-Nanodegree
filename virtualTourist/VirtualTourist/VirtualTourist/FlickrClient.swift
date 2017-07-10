//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Jordan  on 7/10/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation

class FlickrClient {
    
    // MARK: GET
    // We need to pass in the query string parameters (which include the method)
    func taskForGETMethod(parameters: String?, completionHandlerForGET: @escaping (_ deserializedData: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let urlString = Flickr.APIScheme + Flickr.APIHost + Flickr.APIPath + parameters!
        print(urlString)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(String(describing: error?.localizedDescription))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            // Parse raw JSON and pass values for (deserializedData, error) to completionHandlerForGET, rather than the traditional "in" followed by a code block. This has the effect of "bubbling up" the completion handler arguments.
            self.parseJSONWithCompletionHandler(data, completionHandlerForParsingJSON: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
        
    }
    
    // Deserialize raw (binary) JSON and cast it into a useable Foundation object (AnyObject).
    // parseJSONWithCompletionHandler gets called at the bottom of taskForGETMethod.
    private func parseJSONWithCompletionHandler(_ data: Data, completionHandlerForParsingJSON: (_ deserializedData: AnyObject?, _ error: NSError?) -> Void) {
        
        var deserializedData: AnyObject! = nil
        do {
            deserializedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            // If there's an error, the completion handler is passed the arguments below.
            completionHandlerForParsingJSON(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        // If there's no error, the completion handler is passed the arguments below.
        completionHandlerForParsingJSON(deserializedData, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}

extension FlickrClient {
    
    // The HTTP response for the photos is a dictionary.
    func getLocationPhotos(latitude: Double, longitude: Double, pageNumber: Int, completionHandlerForPhotos: @escaping (_ success: Bool, _ urlArray: [String]?, _ error: NSError?) -> Void) {
        
        let latString = String(describing: latitude)
        let lonString = String(describing: longitude)
        
        // Build the query string parameters to pass into taskForGET.
        let parameters = FlickrParameterKeys.Method + FlickrParameterValues.SearchMethod + "&" + FlickrParameterKeys.APIKey + FlickrParameterValues.APIKey + "&" + FlickrParameterKeys.Latitude + latString + "&" + FlickrParameterKeys.Longitude + lonString + "&" + FlickrParameterKeys.Extras + FlickrParameterValues.MediumURL + "&" + FlickrParameterKeys.Format + FlickrParameterValues.ResponseFormat + "&" + FlickrParameterKeys.NoJSONCallback + "&" + FlickrParameterValues.DisableJSONCallback + "&" + FlickrParameterKeys.PerPage + FlickrParameterValues.PerPage + "&" + FlickrParameterKeys.Page + "\(pageNumber)"
        
        taskForGETMethod(parameters: parameters) { (deserializedData, error) in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPhotos(false, nil, NSError(domain: "completionHandlerForGET", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(error?.localizedDescription ?? <#default value#>)")
                return
            }
            
            guard (deserializedData != nil) else {
                sendError(error: "No results were found.")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = deserializedData?[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                sendError(error: "Flickr API returned an error. See error code and message in \(deserializedData ?? <#default value#>)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosContainer = deserializedData?[FlickrResponseKeys.Photos] as? [String:AnyObject], let photosArray = photosContainer[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError(error: "Cannot find keys '\(FlickrResponseKeys.Photos)' and '\(FlickrResponseKeys.Photo)' in \(deserializedData ?? <#default value#>)")
                return
            }
            
            var urlArray = [String]()
            
            for photo in photosArray {
                guard let url = photo[FlickrResponseKeys.MediumURL] as? String else {
                    sendError(error: "Cannot find url")
                    return
                }
                
                urlArray.append(url)
            }
            
            // In this completion handler, we just retrieve the urlArray (urls) rather than downloading the actual images themselves (type Data), because that is very resource intensive and causes the images to load very slowly.
            
            completionHandlerForPhotos(true, urlArray, nil)
            
        }
    }
    
    // Find out how many pages of photos a location has, so that you can return a random page number in that range when the user refreshes the collection.
    func getNumberOfPages(latitude: Double, longitude: Double, completionHandlerForPhotos: @escaping (_ success: Bool, _ numberOfPagesInt: Int?, _ error: NSError?) -> Void) {
        
        let latString = String(describing: latitude)
        let lonString = String(describing: longitude)
        
        // Build the query string parameters to pass into taskForGET.
        let parameters = FlickrParameterKeys.Method + FlickrParameterValues.SearchMethod + "&" + FlickrParameterKeys.APIKey + FlickrParameterValues.APIKey + "&" + FlickrParameterKeys.Latitude + latString + "&" + FlickrParameterKeys.Longitude + lonString + "&" + FlickrParameterKeys.Extras + FlickrParameterValues.MediumURL + "&" + FlickrParameterKeys.Format + FlickrParameterValues.ResponseFormat + "&" + FlickrParameterKeys.NoJSONCallback + FlickrParameterValues.DisableJSONCallback + "&" + FlickrParameterKeys.PerPage + FlickrParameterValues.PerPage
        
        taskForGETMethod(parameters: parameters) { (deserializedData, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPhotos(false, nil, NSError(domain: "completionHandlerForGET", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(error?.localizedDescription ?? <#default value#>)")
                return
            }
            
            guard (deserializedData != nil) else {
                sendError(error: "No results were found.")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = deserializedData?[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                sendError(error: "Flickr API returned an error. See error code and message in \(deserializedData ?? <#default value#>)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosContainer = deserializedData?[FlickrResponseKeys.Photos] as? [String:AnyObject], let photosArray = photosContainer[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError(error: "Cannot find keys '\(FlickrResponseKeys.Photos)' and '\(FlickrResponseKeys.Photo)' in \(deserializedData ?? <#default value#>)")
                return
            }
            
            /* GUARD: Is the "pages" key in our result? */
            guard let numberOfPagesInt = photosContainer[FlickrResponseKeys.Pages] as? Int else {
                sendError(error: "Cannot find key '\(FlickrResponseKeys.Pages)' in \(deserializedData ?? <#default value#>)")
                return
            }
            
            var urlArray = [String]()
            
            for photo in photosArray {
                guard let url = photo[FlickrResponseKeys.MediumURL] as? String else {
                    sendError(error: "Cannot find url")
                    return
                }
                
                urlArray.append(url)
            }
            
            // In this completion handler, we just retrieve the urlArray (urls) rather than downloading the actual images themselves (type Data), because that is very resource intensive and causes the images to load very slowly.
            
            completionHandlerForPhotos(true, numberOfPagesInt, nil)
            
        }
    }
    
    // Helper method: given a URL, get the UIImage to load in the collection view cell
    func downloadPhotoWith(url: String, completionHandlerForDownload: @escaping (_ success: Bool, _ imageData: NSData?, _ error: Error?) -> Void) {
        
        let session = URLSession.shared
        
        // Convert the url string to URL so that it can be passed into dataTask(with url:)
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
