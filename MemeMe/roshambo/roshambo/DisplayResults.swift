//
//  DisplayResults.swift
//  roshambo
//
//  Created by Jordan  on 10/21/16.
//  Copyright © 2016 Jordan . All rights reserved.
//

import UIKit

class DisplayResults: UIViewController {
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var opponentImageView: UIImageView!
    @IBOutlet var resultsImageView: UIImageView!
    
    var opponentsChoice: String!
    var userInput: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opponentsPlay()
        displayResults()
    }
    
    func opponentsPlay() {
        var choices = ["rock","paper","scissors"]
        let randomIndex = Int(arc4random_uniform(UInt32(choices.count)))
        opponentsChoice = choices[randomIndex]
        
        switch (opponentsChoice) {
        case "rock":
            opponentImageView.image = UIImage(named: "rock.png")
        case "scissors":
            opponentImageView.image = UIImage(named: "scissors.png")
        case "paper":
            opponentImageView.image = UIImage(named: "paper.png")
        default:
            print("no choice")
        }
        
        
    }
    
    func displayResults() {
        switch (userInput!, opponentsChoice!) {
        case ("rock", "scissors"):
            resultsImageView.image = UIImage(named: "RockCrushesScissors.png")
        case ("rock", "paper"):
            resultsImageView.image = UIImage(named: "PaperCoversRock.png")
        case ("paper", "scissors"):
            resultsImageView.image = UIImage(named: "ScissorsCutsPaper.png")
        default:
            resultsImageView.image = UIImage(named: "itsATie.png")
        }
    }
}
