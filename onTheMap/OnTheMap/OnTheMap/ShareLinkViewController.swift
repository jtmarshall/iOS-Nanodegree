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
    }
    
    // Submit Button
    @IBAction func submitButtonPressed(_ sender: Any) {
        self.locate(mapString: mapString)
    }
    
    // POST
    func taskForPOSTMethodParse(newUniqueKey: String, newMapString: String, newMediaURL: String, newLatitude: String, newLongitude: String) {
        
        let request = NSMutableURLRequest(url: URL(string: StudentInfo.StudentLocation.studentLocationURL)!)
        request.httpMethod = "POST"
        request.addValue(StudentInfo.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfo.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(newUniqueKey)\", \"firstName\": \"\(StudentInfo.NewStudent.firstName)\", \"lastName\": \"\(StudentInfo.NewStudent.lastName)\",\"mapString\": \"\(newMapString)\", \"mediaURL\": \"\(newMediaURL)\",\"latitude\": \(newLatitude), \"longitude\": \(newLongitude)}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("Error with POST request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Status code doesn't conform to 2xx.")
                return
            }
            
            guard let data = data else {
                print("Request returned no data.")
                return
            }
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)

            
            var parsedResult: [String:AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print ("Couldn't parse data as JSON: '\(data)'")
                return
            }
            
            guard let objectID = parsedResult["objectID"] as? String else {
                print ("No objectId")
                return
            }
            
            StudentInfo.NewStudent.objectID = objectID
            print("Your objectID: \(objectID)")
        }
        task.resume()
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
                print("There is an error")
                return
            }
            for response in (localSearchResponse?.mapItems)! {
                placeMarks.append(response.placemark)
                print("Response: \(response)")
            }
            
            self.mapView.showAnnotations([placeMarks[0]], animated: false)
            
            let newLatitude = String(placeMarks[0].coordinate.latitude)
            let newLongitude = String(placeMarks[0].coordinate.longitude)
            let newMapString = placeMarks[0].description
            let newUniqueKey = StudentInfo.NewStudent.uniqueKey
            let newMediaURL = self.linkTextField.text!
            
            self.taskForPOSTMethodParse(newUniqueKey: newUniqueKey, newMapString: newMapString, newMediaURL: newMediaURL, newLatitude: newLatitude, newLongitude: newLongitude)
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
            self.present(controller!, animated: true, completion: nil)
        }
    }
    
    // Cancel Submission
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
