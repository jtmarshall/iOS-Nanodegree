//
//  RollViewController.swift
//  Dice
//
//  Created by Jason Schatz on 11/6/14.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import UIKit

// MARK: - RollViewController: UIViewController

class RollViewController: UIViewController {
    
    // MARK: Generate Dice Value
    
    // randomly generates a Int from 1 to 6
    func randomDiceValue() -> Int {
        // generate a random Int32 using arc4Random
        let randomValue = 1 + arc4random() % 6
        // return a more convenient Int, initialized with the random value
        return Int(randomValue)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! DiceViewController
        
        controller.firstValue = self.randomDiceValue()
        controller.secondValue = self.randomDiceValue()
    }
    
    @IBAction func rollTheDice() {
        var controller:DiceViewController
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("DiceViewController") as!
            DiceViewController
        
        controller.firstValue = self.randomDiceValue()
        controller.secondValue = self.randomDiceValue()
        
        self.presentViewController(controller, animated: true, completion: nil)
        }
}
