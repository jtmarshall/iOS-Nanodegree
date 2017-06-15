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
    
    //MARK: Outlets
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var mapString = StudentInformation.NewStudent.address
    let geoCoder = CLGeocoder()
    
    let initialLocation = CLLocation(latitude: StudentInformation.StudentLocation.latitude, longitude: StudentInformation.StudentLocation.longitute)
    
    override func viewDidLoad() {
        mapView.delegate = self
        StudentInformation.NewStudent.mediaURL = linkTextField.text!
        
        //center map on student's location
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
    
    //define zoom radius of location
    let regionRadius: CLLocationDistance = 5000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        //        self.addressOnMap(address: mapString)
        self.locate(mapString: mapString)
    }
    
    func taskForPOSTMethodParse(newUniqueKey: String, newMapString: String, newMediaURL: String, newLatitude: String, newLongitude: String) {
        
        let request = NSMutableURLRequest(url: URL(string: StudentInformation.StudentLocation.studentLocationURL)!)
        request.httpMethod = "POST"
        request.addValue(StudentInformation.StudentLocation.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInformation.StudentLocation.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(newUniqueKey)\", \"firstName\": \"\(StudentInformation.StudentLocation.firstName)\", \"lastName\": \"\(StudentInformation.StudentLocation.lastName)\",\"mapString\": \"\(newMapString)\", \"mediaURL\": \"\(newMediaURL)\",\"latitude\": \(newLatitude), \"longitude\": \(newLongitude)}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("Something went wrong with POST request: \(String(describing: error))")
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
            //            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            
            var parsedResult: [String:AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print ("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let objectID = parsedResult["objectID"] as? String else {
                print ("There is no objectId")
                return
            }
            
            StudentInformation.NewStudent.objectID = objectID
            print("Your objectID: \(objectID)")
        }
        
        task.resume()
    }
    
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
            let newUniqueKey = StudentInformation.NewStudent.uniqueKey
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
