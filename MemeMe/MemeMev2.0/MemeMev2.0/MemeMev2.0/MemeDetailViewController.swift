//
//  MemeDetailViewController.swift
//  MemeMeV1.0
//
//  Created by Jordan  on 1/9/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    //set variables
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var Edit: UIBarButtonItem!
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        //set the memed Image as what to display in the imageview
        memeImageView.image = meme.memedImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setRightBarButton(Edit, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}
