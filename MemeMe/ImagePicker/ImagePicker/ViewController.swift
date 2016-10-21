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

    @IBAction func experiment() {
        let nextController = UIImagePickerController()
        self.present(nextController, animated: true, completion: nil)
    }

}

