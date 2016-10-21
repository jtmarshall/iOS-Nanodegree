//  DiceViewController.swift
//  Dice
//
//  Created by Jason Schatz on 11/6/14.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import Foundation
import UIKit

// MARK: - DiceViewController: UIViewController

class DiceViewController: UIViewController {

    // MARK: Properties
    
    var firstValue: Int?
    var secondValue: Int?
    
    // MARK: Outlets
    
    @IBOutlet var firstDie: UIImageView!
    @IBOutlet var secondDie: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        
        // The dice will only appear if firstValue and secondValue have been set
        if let firstValue = self.firstValue {
            self.firstDie.image = UIImage(named: "d\(firstValue)")
        } else {
            self.firstDie.image = nil;
        }
        
        if let secondValue = self.secondValue {
            self.secondDie.image = UIImage(named: "d\(secondValue)")
        } else {
            self.secondDie.image = nil
        }
        
        self.firstDie.alpha = 0
        self.secondDie.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.3) {
            self.firstDie.alpha = 1
            self.secondDie.alpha = 1
        }
    }
    
    // MARK: Get Image for Dice Value
    
    // accepts a conditional Int, and returns an dice image, or nil
    func imageForValue(value: Int?) -> UIImage? {
        return nil
    }
    
    // MARK: Action
    
    @IBAction func dismiss() {
        // dismiss this view controller
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
