//
//  ViewController.swift
//  roshambo
//
//  Created by Jordan  on 10/21/16.
//  Copyright © 2016 Jordan . All rights reserved.
//

import UIKit

class BeginMatch: UIViewController {
    var userInput: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func pickRock() {
        userInput = "rock"
        performSegue(withIdentifier: "play", sender: userInput)
    }
    
    @IBAction func pickPaper() {
        userInput = "paper"
        performSegue(withIdentifier: "play", sender: userInput)
    }
    
    @IBAction func pickScissors() {
        userInput = "scissors"
        performSegue(withIdentifier: "play", sender: userInput)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! DisplayResults
        controller.userInput = userInput
    }
}

