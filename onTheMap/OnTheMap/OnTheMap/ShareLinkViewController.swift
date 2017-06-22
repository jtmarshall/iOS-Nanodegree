//
//  ShareLinkViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 6/15/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class ShareLinkViewController: UIViewController, MKMapViewDelegate {
    
    // Buttons
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var mapString = StudentInfo.NewStudent.address
    let geoCoder = CLGeocoder()
    let initialLocation = CLLocation(latitude: StudentInfo.StudentLocation.latitude, longitude: StudentInfo.StudentLocation.longitute)
    
    override func viewDidLoad() {
        mapView.delegate = self
        StudentInfo.NewStudent.mediaURL = linkTextField.text!
        
        // Center map to student's preview locale
        geoCoder.geocodeAddressString(mapString) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    return
            }
            self.centerMapOnLocation(location: location)
        }
    }
    
    // Zoom of location
    let regionRadius: CLLocationDistance = 5000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // Add pinpoint on map
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        // For some reason we have to select and deselect each annotation for it to appear without dragging the map around...
        mapView.selectAnnotation(annotation, animated: false)
        mapView.deselectAnnotation(annotation, animated: false)
    }
    
    // Submit Button
    @IBAction func submitButtonPressed(_ sender: Any) {
        self.locate(mapString: mapString)
    }
    
    // Locate
    func locate(mapString: String) {
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = mapString
        localSearchRequest.region = mapView.region
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) in
            var placeMarks = [MKPlacemark]()
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: "Cannot POST", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
                
                let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                alertWindow.rootViewController = UIViewController()
                alertWindow.windowLevel = UIWindowLevelAlert + 1;
                alertWindow.makeKeyAndVisible()
                alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                return
            }
            for response in (localSearchResponse?.mapItems)! {
                placeMarks.append(response.placemark)
            }
            
            self.mapView.showAnnotations([placeMarks[0]], animated: false)
            
            let newLatitude = String(placeMarks[0].coordinate.latitude)
            let newLongitude = String(placeMarks[0].coordinate.longitude)
            let newMapString = placeMarks[0].description
            let newUniqueKey = StudentInfo.NewStudent.uniqueKey
            let newMediaURL = self.linkTextField.text!
            
            UdacityClient.sharedInstance().POSTMethodParse(newUniqueKey: newUniqueKey, newMapString: newMapString, newMediaURL: newMediaURL, newLatitude: newLatitude, newLongitude: newLongitude, completion: { (success, error) in
                guard (error == nil) else {
                    UdacityClient.sharedInstance().showError(errorString: error!)
                    return
                }
            })
            
            self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: nil)
            //let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
            //self.present(controller!, animated: true, completion: nil)
        }
    }
    
    // Cancel Submission
    @IBAction func cancelButtonPressed(_ sender: Any) {
        // Dismiss both Share Link and Post View
        self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
