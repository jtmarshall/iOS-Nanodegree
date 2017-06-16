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
    
    @IBOutlet weak var mapView: MKMapView!
        
    var locationJSON = [[String:AnyObject]]()
    var address = StudentInformation.NewStudent.address
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        taskForGETMultipleStudentLocationsMethod { (success, locationJSON, errorString) in
            
            let locations = StudentInformation.StudentData.studentInformation
            print("Locations: \(locations)")
            var annotations = [MKPointAnnotation]()
            
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
                    
                    annotations.append(annotation)
                }
            }
            
            self.mapView.addAnnotations(annotations)
        }
    }
    
    //Pin button pressed
    @IBAction func pinButtonPressed(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: Map view delegate
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
                UIApplication.shared.open(NSURL(string: toOpen)! as URL, options: [:], completionHandler: nil)
            }
        }
    }
    
    //MARK: Get location of multiple students
    func taskForGETMultipleStudentLocationsMethod(completionHandlerForMultipleStudentLocations: @escaping (_ success: Bool, _ locationJSON: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: StudentInformation.StudentLocation.studentLocationURL)!)
        request.addValue(StudentInformation.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInformation.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("Something went wrong with your POST request: \(String(describing: error))")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your status code does not conform to 2xx.")
                return
            }
            guard let data = data else {
                print("The request returned no data.")
                return
            }
            
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse data as JSON: \(data)")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                print("No result found")
                return
            }
            
            StudentInformation.StudentData.studentInformation = results
            completionHandlerForMultipleStudentLocations(true, StudentInformation.StudentData.studentInformation, nil)
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    //MARK: Get location of single student
    func taskForGETSingleStudentLocation() -> URLSessionDataTask {
        
        let urlString = StudentInformation.StudentLocation.studentLocationURL
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue(StudentInformation.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInformation.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("Something went wrong with your POST request: \(String(describing: error))")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your status code does not conform to 2xx.")
                return
            }
            guard let data = data else {
                print("The request returned no data.")
                return
            }
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
        return task
    }
}
