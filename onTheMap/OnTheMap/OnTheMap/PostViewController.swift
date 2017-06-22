//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 6/12/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation

class PostViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    var alertView: UIAlertController?
    // Added from storyboard
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationText: UITextField!
    
//    @IBAction func findLocation(_ sender: AnyObject) {
//        StudentInfo.NewStudent.address = locationText.text!
//    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    var geocoder = CLGeocoder()
    
    // Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure activity indicator is off
        activityIndicator.stopAnimating()
        // For keyboard disapper
        locationText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func findOnMapPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        locationText.resignFirstResponder()
        
        if locationText.text != nil {
            
            StudentInfo.NewStudent.address = locationText.text!
            
            geocoder.geocodeAddressString(StudentInfo.NewStudent.address) { placemarks, error in
                guard (error == nil) else {
                    // Elegance has failed us, time for brute force!
                    let alertController = UIAlertController(title: "Error", message: "Invalid Coordinates", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
                    
                    let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                    alertWindow.rootViewController = UIViewController()
                    alertWindow.windowLevel = UIWindowLevelAlert + 1;
                    alertWindow.makeKeyAndVisible()
                    alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                    return
                }
                
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
            
        } else {
            // Error checking alert
            self.alertView = UIAlertController(title: "Error!", message: "Error Geocoding.", preferredStyle: UIAlertControllerStyle.alert)
            self.alertView?.addAction(UIAlertAction(title: "OK", style: .default) { action in
                self.alertView?.dismiss(animated: true, completion: nil)
            })
            self.present(self.alertView!, animated: true)
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            // Error checking alert
            self.alertView = UIAlertController(title: "Error!", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
            self.alertView?.addAction(UIAlertAction(title: "OK", style: .default) { action in
                self.alertView?.dismiss(animated: true, completion: nil)
            })
            self.present(self.alertView!, animated: true)
            
            return
            //locationText.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                locationText.text = "\(coordinate.latitude), \(coordinate.longitude)"
            } else {
                // Error checking alert
                self.alertView = UIAlertController(title: "Error!", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
                self.alertView?.addAction(UIAlertAction(title: "OK", style: .default) { action in
                    self.alertView?.dismiss(animated: true, completion: nil)
                })
                self.present(self.alertView!, animated: true)
                
                return
            }
            // Show add new link page
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "ShareLinkViewController") as! ShareLinkViewController
            self.present(controller, animated: true, completion: nil)
            // Activity Indicator
            self.activityIndicator.stopAnimating()
            StudentInfo.StudentLocation.latitude = (location?.coordinate.latitude)!
            StudentInfo.StudentLocation.longitute = (location?.coordinate.longitude)!
        }
    }
    
    // Cancel Button Press
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// Keyboard move functionality
extension PostViewController {
    
    // Keyboard disappear after enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationText.resignFirstResponder()
        return true
    }
    
    // Move text field up for keyboard
    func keyboardWillShow(_ notification:Notification) {
        if locationText.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}
