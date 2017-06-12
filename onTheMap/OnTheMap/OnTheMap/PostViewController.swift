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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationText.delegate = self
    }
    
    @IBOutlet weak var LocationText: UITextField!
    
    
    @IBAction func findOnTheMap(_ sender: AnyObject) {
        
        Constants.newStudent.address = LocationText.text!
    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
