//
//  ViewController.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var phraseSearchButton: UIButton!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latLonSearchButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phraseTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Search Actions
    
    @IBAction func searchByPhrase(_ sender: AnyObject) {

        userDidTapView(self)
        setUIEnabled(false)
        
        if !phraseTextField.text!.isEmpty {
            photoTitleLabel.text = "Searching..."
            // TODO: Set necessary parameters!
            let methodParameters: [String: String?] = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod, Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey, Constants.FlickrParameterKeys.Text: phraseTextField.text, Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL, Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch, Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat, Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback]
            
            displayImageFromFlickrBySearch(methodParameters as [String : AnyObject])
        } else {
            setUIEnabled(true)
            photoTitleLabel.text = "Phrase Empty."
        }
    }
    
    @IBAction func searchByLatLon(_ sender: AnyObject) {

        userDidTapView(self)
        setUIEnabled(false)
        
        if isTextFieldValid(latitudeTextField, forRange: Constants.Flickr.SearchLatRange) && isTextFieldValid(longitudeTextField, forRange: Constants.Flickr.SearchLonRange) {
            photoTitleLabel.text = "Searching..."
            // TODO: Set necessary parameters!
            let methodParameters: [String: String?] = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod, Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey, Constants.FlickrParameterKeys.BoundingBox: bboxString(), Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL, Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch, Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat, Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback]
            displayImageFromFlickrBySearch(methodParameters as [String : AnyObject])
        }
        else {
            setUIEnabled(true)
            photoTitleLabel.text = "Lat should be [-90, 90].\nLon should be [-180, 180]."
        }
    }
    
    private func bboxString() -> String {
        if let lat = Double(latitudeTextField.text!), let long = Double(longitudeTextField.text!) {
            let upperLong = min(Constants.Flickr.SearchLonRange.1, long + Constants.Flickr.SearchBBoxHalfHeight)
            
            let lowerLong = max(Constants.Flickr.SearchLonRange.0, long - Constants.Flickr.SearchBBoxHalfHeight)
            
            let upperLat = min(Constants.Flickr.SearchLatRange.1, lat + Constants.Flickr.SearchBBoxHalfWidth)
            
            let lowerLat = max(Constants.Flickr.SearchLatRange.0, lat - Constants.Flickr.SearchBBoxHalfWidth)
            return "\(lowerLong),\(lowerLat),\(upperLong),\(upperLat)"
        } else {
            return "0,0,0,0"
        }
    }
    
    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // the network request
        let task = session.dataTask(with: request) { (data, response, error) in
            // if an error
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.photoTitleLabel.text = "No photo return, try again."
                    self.photoImageView.image = nil
                }
            }
            // check if error happened
            guard (error == nil) else {
                displayError(error: "There was an error with the request: \(String(describing: error))")
                return
            }
            
            // check for 200 response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    displayError(error: "Request returned a status other than 2xx")
                    return
            }
            
            // was data returned?
            guard let data = data else {
                displayError(error: "No data returned.")
                return
            }
            
            // parse data
            let parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                displayError(error: "Could not parse JSON. \(data)")
                return
            }
            
            // check if API returned error
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                    displayError(error: "Flickr API returned an error. \(parsedResult)")
                    return
            }
            
            // check for 'photos' key
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
                displayError(error: "Cannot find key \(Constants.FlickrResponseKeys.Photos)")
                return
            }
            
            // check for THE 'photo'
//            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
//                displayError(error: "Cannot find key \(Constants.FlickrResponseKeys.Photo)")
//                return
//            }
            
            // check for 'pages' so we can request a random page in that range
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError(error: "Cannot find any pages")
                return
            }
            // check if more pages than the defualt 40
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit)))+1
            // recursive call
            self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage)
        }
        // starts the task
        task.resume()
    }
    
    // Overloaded function for recursive call
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int) {
        // create session and request
        let session = URLSession.shared
        
        var methParamsWithPage = methodParameters
        methParamsWithPage[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // the network request
        let task = session.dataTask(with: request) { (data, response, error) in
            // if an error
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.photoTitleLabel.text = "No photo return, try again."
                    self.photoImageView.image = nil
                }
            }
            // check if error happened
            guard (error == nil) else {
                displayError(error: "There was an error with the request: \(String(describing: error))")
                return
            }
            
            // check for 200 response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError(error: "Request returned a status other than 2xx")
                return
            }
            
            // was data returned?
            guard let data = data else {
                displayError(error: "No data returned.")
                return
            }
            
            // parse data
            let parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                displayError(error: "Could not parse JSON. \(data)")
                return
            }
            
            // check if API returned error
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError(error: "Flickr API returned an error. \(parsedResult)")
                return
            }
            
            // check for 'photos' key
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
                displayError(error: "Cannot find key \(Constants.FlickrResponseKeys.Photos)")
                return
            }
            
            // check for THE 'photo'
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError(error: "Cannot find key \(Constants.FlickrResponseKeys.Photo)")
                return
            }
            
            if photosArray.count == 0 {
                displayError(error: "No photos found")
                return
            } else {
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                // check for key 'url_m'
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    displayError(error: "Cannot find key \(Constants.FlickrResponseKeys.MediumURL)")
                    return
                }
                
                let imageURL = URL(string: imageUrlString)
                if let imageData = NSData(contentsOf: imageURL!) {
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.photoImageView.image = UIImage(data: imageData as Data)
                        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                    }
                } else {
                    displayError(error: "Image does not exist at \(String(describing: imageURL))")
                }
            }
            
        }
        // starts the task
        task.resume()
    }

    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

// MARK: - ViewController: UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(phraseTextField)
        resignIfFirstResponder(latitudeTextField)
        resignIfFirstResponder(longitudeTextField)
    }
    
    // MARK: TextField Validation
    
    func isTextFieldValid(_ textField: UITextField, forRange: (Double, Double)) -> Bool {
        if let value = Double(textField.text!), !textField.text!.isEmpty {
            return isValueInRange(value, min: forRange.0, max: forRange.1)
        } else {
            return false
        }
    }
    
    func isValueInRange(_ value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
}

// MARK: - ViewController (Configure UI)

private extension ViewController {
    
     func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        phraseTextField.isEnabled = enabled
        latitudeTextField.isEnabled = enabled
        longitudeTextField.isEnabled = enabled
        phraseSearchButton.isEnabled = enabled
        latLonSearchButton.isEnabled = enabled
        
        // adjust search button alphas
        if enabled {
            phraseSearchButton.alpha = 1.0
            latLonSearchButton.alpha = 1.0
        } else {
            phraseSearchButton.alpha = 0.5
            latLonSearchButton.alpha = 0.5
        }
    }
}

// MARK: - ViewController (Notifications)

private extension ViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
