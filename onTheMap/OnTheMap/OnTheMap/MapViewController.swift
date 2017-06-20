//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var logout: UIBarButtonItem!
    
    var locationJSON = [[String:AnyObject]]()
    var address = StudentInfo.NewStudent.address
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Saw in forumns that this was suggested to be wrapped inside 'performUIUpdatesOnMain' but it works the same without that...
        UdacityClient.sharedInstance().getMultipleStudentLocationsMethod { (success, locationJSON, errorString) in
            let locations = StudentInfo.StudentData.studentInformation
            print("Locations: \(locations)")
            
            // Iterate through dictionary
            for dictionary in locations {
                if let latitude = dictionary["latitude"] as? Double, let longitude = dictionary["longitude"] as? Double {
                    print("Longitude: \(longitude), Latitude: \(latitude)")
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let firstName = dictionary["firstName"] as! String
                    let lastName = dictionary["lastName"] as! String
                    let mediaURL = dictionary["mediaURL"] as! String
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(firstName) \(lastName)"
                    annotation.subtitle = mediaURL
                    
                    // Add the annotation per student
                    self.mapview.addAnnotation(annotation)
                    // For some reason we have to select and deselect each annotation for it to appear without dragging the map around...
                    self.mapview.selectAnnotation(annotation, animated: false)
                    self.mapview.deselectAnnotation(annotation, animated: false)
                }
            }
        }
    }
    
    // Pin button takes you to new post
    @IBAction func pinButtonPressed(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        present(controller, animated: true, completion: nil)
    }
    
    // Logout Button
    @IBAction func logout(_ sender: AnyObject) {
        
        UdacityClient.sharedInstance().deleteViewController() {(success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                // Popup alert
                let popAlert = UIAlertController(title: "Error!", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
                popAlert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                    popAlert.dismiss(animated: true, completion: nil)
                })
                self.present(popAlert, animated: true)
            }
        }
    }
    
    // Map view delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                UIApplication.shared.canOpenURL(NSURL(string: toOpen)! as URL)
            } else {
                // Popup alert
                let popAlert = UIAlertController(title: "Error!", message: "Can't open URL!", preferredStyle: UIAlertControllerStyle.alert)
                popAlert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                    popAlert.dismiss(animated: true, completion: nil)
                })
                self.present(popAlert, animated: true)
            }
        }
    }
}
