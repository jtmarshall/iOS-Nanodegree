//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Jordan  on 7/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var coordinate: CLLocationCoordinate2D?
    var annotation: MKPointAnnotation?
    var latitude: Double?
    var longitude: Double?
    var pinsArray: [Pin]?
    var tappedPin: Pin?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    // Get stack
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self as MKMapViewDelegate
        
        // So we can add a pin
        activateGestureRecognizer()
        
        // Load all pins stored
        loadPins()
    }
    
    // Adding a pin
    func addPin(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Start using gestures
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            // Returns a CGPoint
            let pressedLocation = gestureRecognizer.location(in: mapView)
            
            // Convert CGPoint to CLLocationCoordinate2D
            self.coordinate = mapView.convert(pressedLocation, toCoordinateFrom: mapView)
            
            // Add annotation to map
            self.annotation = MKPointAnnotation()
            self.annotation?.coordinate = self.coordinate!
            
            // Store lat and long values for Flickr query string
            self.latitude = self.coordinate?.latitude
            self.longitude = self.coordinate?.longitude
        }
        
        // Gestures on changes
        if gestureRecognizer.state == UIGestureRecognizerState.changed {
            
            // Returns a CGPoint
            let pressedLocation = gestureRecognizer.location(in: mapView)
            
            // Convert CGPoint to CLLocationCoordinate2D
            self.coordinate = mapView.convert(pressedLocation, toCoordinateFrom: mapView)
            
            // Add annotation to map
            self.annotation = MKPointAnnotation()
            self.annotation?.coordinate = self.coordinate!
            
            // Store lat and long
            self.latitude = self.coordinate?.latitude
            self.longitude = self.coordinate?.longitude
            
        }
        
        // Gestures ending
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            // Returns a CGPoint
            let pressedLocation = gestureRecognizer.location(in: mapView)
            
            // Convert CGPoint to CLLocationCoordinate2D
            self.coordinate = mapView.convert(pressedLocation, toCoordinateFrom: mapView)
            
            // Add annotation to map.
            self.annotation = MKPointAnnotation()
            self.annotation?.coordinate = self.coordinate!
            self.mapView.addAnnotation(annotation!)
            
            // Store lat and long
            self.latitude = self.coordinate?.latitude
            self.longitude = self.coordinate?.longitude
            
            // Pin object
            let pin = Pin(latitude: self.latitude!, longitude: self.longitude!, context: stack.context)
            pinsArray?.append(pin)
            
            // Save pin
            do {
                try stack.context.save()
            } catch {
                print("Error saving pin")
            }
        }
    }
    
    // Activate UIGestureRecognizer for addPin to work
    func activateGestureRecognizer() {
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        longPress.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(longPress)
    }
    
    // Load pins created in previous app loads
    func loadPins() {
        
        var annotationsArray = [MKPointAnnotation]()
        
        // Fetch request
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        // Grab the Pin objects
        do {
            pinsArray = try stack.context.fetch(fr) as? [Pin]
        } catch {
            print(error.localizedDescription)
        }
        
        for pin in pinsArray! {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude),longitude: CLLocationDegrees(pin.longitude))
            annotationsArray.append(annotation)
        }
        
        mapView.addAnnotations(annotationsArray)
    }
}

// MKMapViewDelegate
extension TravelLocationsMapView: MKMapViewDelegate {
    
    // When pin is tapped, move to PhotoAlbumView
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbum") as! PhotoAlbumView
        
        self.navigationController?.show(controller, sender: navigationController)
        
        // Pass tapped pin coordinates to PhotoAlbumView
        controller.coordinate = view.annotation?.coordinate
        controller.latitude = view.annotation?.coordinate.latitude
        controller.longitude = view.annotation?.coordinate.longitude
        
        // Iterate through pins on map to get one that matches tapped
        for pin in pinsArray! {
            if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude {
                self.tappedPin = pin
            }
        }
        
        // Object for PhotoAlbumView
        controller.tappedPin = self.tappedPin
        
        // Deselect pin so it can be reselected on return from PhotoAlbumView
        self.mapView.deselectAnnotation(self.annotation, animated: true)
    }
}
