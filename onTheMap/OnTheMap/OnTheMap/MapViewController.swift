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
    
    var locationJSON = [[String:AnyObject]]()
    var address = StudentInfo.NewStudent.address
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getMultipleStudentLocationsMethod { (success, locationJSON, errorString) in
            let locations = StudentInfo.StudentData.studentInformation
            print("Locations: \(locations)")
            
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
                    
                    // Add the annotation (student)
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
    
    //MARK: Get location of all students
    func getMultipleStudentLocationsMethod(completionHandlerForMultipleStudentLocations: @escaping (_ success: Bool, _ locationJSON: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: StudentInfo.StudentLocation.studentLocationURL)!)
        request.addValue(StudentInfo.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfo.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
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
            
            StudentInfo.StudentData.studentInformation = results
            completionHandlerForMultipleStudentLocations(true, StudentInfo.StudentData.studentInformation, nil)
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    //MARK: Get location of single student
    func getSingleStudentLocation() -> URLSessionDataTask {
        let urlString = StudentInfo.StudentLocation.studentLocationURL
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue(StudentInfo.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfo.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
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
