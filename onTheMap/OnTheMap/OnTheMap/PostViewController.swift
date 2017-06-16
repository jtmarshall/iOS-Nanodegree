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

class PostViewController: UIViewController, UIApplicationDelegate, UINavigationControllerDelegate,UITextFieldDelegate, MKMapViewDelegate {
    
    var mapView: MKMapView!
    
    @IBOutlet weak var locationText: UITextField!
    
    @IBAction func findLocation(_ sender: AnyObject) {
        StudentInfo.NewStudent.address = locationText.text!
    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var geocoder = CLGeocoder()
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if locationText.text != nil {
            
            StudentInfo.NewStudent.address = locationText.text!
            
            //            geocoder.geocodeAddressString(Constants.StudentLocation.mapString) { (placemarks, error) in
            geocoder.geocodeAddressString(StudentInfo.NewStudent.address) { (placemarks, error) in
                
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
            
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "ShareLinkViewController") as! ShareLinkViewController
            self.present(controller, animated: true, completion: nil)
            
            //test code
            print("second: \(StudentInfo.StudentLocation.longitute)")
            print("second: \(StudentInfo.StudentLocation.latitude)")
        } else {
            print("No location entered")
            //TODO: AlertController
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            locationText.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                locationText.text = "\(coordinate.latitude), \(coordinate.longitude)"
            } else {
                locationText.text = "Location not found"
            }
            
            StudentInfo.StudentLocation.latitude = (location?.coordinate.latitude)!
            StudentInfo.StudentLocation.longitute = (location?.coordinate.longitude)!
        }
    }
    
    //Dismiss viewController
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PostViewController {
    
    //Make keyboard disappear upon pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Move textFields up to not be covered by keyboard
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
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
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
