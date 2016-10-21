//
//  ViewController.swift
//  ImagePicker
//
//  Created by Jordan  on 10/21/16.
//  Copyright © 2016 Jordan . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //image picker controller
    @IBAction func experiment() {
        let nextController = UIImagePickerController()
        self.present(nextController, animated: true, completion: nil)
    }
    
    //activity view controller
    @IBAction func activityViewExperiment() {
        let image = UIImage()
        let nextController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(nextController, animated: true, completion: nil)
    }
    
    //alert view controller
    @IBAction func alertViewExperiment() {
        let nextController = UIAlertController()
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { action in
            self.dismiss(animated: true, completion: nil)
        }
        nextController.addAction(okAction)
        self.present(nextController, animated: true, completion: nil)
    }

}

