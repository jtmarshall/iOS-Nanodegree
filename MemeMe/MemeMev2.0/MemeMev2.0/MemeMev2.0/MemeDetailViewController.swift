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
    
    // MARK: Outlets
    @IBOutlet weak var memeDetailImageView: UIImageView!
    
    @IBOutlet weak var memeDetailTitleLabel: UILabel!
    
    var memeDetail: Meme!
    
    // MARK: Properties
    var memes: [Meme] {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Set the Content Mode to Aspect Fit in Code & Storyboard GUI too.
        memeDetailImageView.contentMode = .scaleAspectFit
        tabBarController?.tabBar.isHidden = true
        memeDetailTitleLabel.text = memeDetail.top
        memeDetailImageView.image = memeDetail.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
}
