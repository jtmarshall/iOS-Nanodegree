//
//  NewLocationViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StudentLocationViewController: UIViewController, MKMapViewDelegate {
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func postPin(_ sender: AnyObject) {
        self.postPinAlert()
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        UdacityClient.sharedInstance().deleteViewController() {(success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(controller, animated: true, completion: nil)
                }
            } else {
                print (errorString)
            }
        }
    }
    
    var locationJSON = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskGetAllStudentLocations(){(success, locationJSON, errorString) in
            
            // The "locations" array is an array of dictionary objects that are similar to the JSON data that you can download from parse.
            let locations = StudentInformation.student.studentInformation
            //print ("locations: \(locations)")
            
            // We will create an MKPointAnnotation for each dictionary in "locations". The
            // point annotations will be stored in this array, and then provided to the map view.
            var annotations = [MKPointAnnotation]()
            
            // The "locations" array is loaded with the sample data below. We are using the dictionaries
            // to create map annotations. This would be more stylish if the dictionaries were being
            // used to create custom structs. Perhaps StudentLocation structs.
            
            for dictionary in locations {
                
                if let lat = dictionary["latitude"] as? Double, let long = dictionary["longitude"] as? Double {
                    print ("lat is \(lat), long is \(long)")
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = dictionary["firstName"] as! String
                    let last = dictionary["lastName"] as! String
                    let mediaURL = dictionary["mediaURL"] as! String
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                /*guard let lat = dictionary["latitude"] as? Double else {
                 print ("There is no lat.")
                 return
                 }
                 guard let long = dictionary["longitude"] as? Double else {
                 print ("There is no long.")
                 return
                 }*/
            }
            
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
            
        }
        
        //self.taskGetAStudentLocation()
        //self.taskPostAStudentLocation()
        //self.taskPutAStudentLocation()
        
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(NSURL(string: toOpen)! as URL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
    
    // GET All Student Locations
    func taskGetAllStudentLocations(_ completionHandlerForStudentLocations: @escaping (_ success: Bool, _ locationJSON: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=10&skip=400&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return
            }
            
            let parsedResult: [String:AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print ("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                print ("No result")
                return
            }
            
            StudentInformation.student.studentInformation = results
            completionHandlerForStudentLocations(true, StudentInformation.student.studentInformation, nil)
        }
        task.resume()
    }
    
    //GET Single Student Location
    func taskGetSingleStudentLocation() -> URLSessionDataTask {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
        return task
    }
    
    func postPinAlert() {
        let alertController = UIAlertController(title: nil, message: "You Currently Have a Posted Location. Overwrite Location?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.cancel){(action) in
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "PostViewController")
            self.present(controller, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
