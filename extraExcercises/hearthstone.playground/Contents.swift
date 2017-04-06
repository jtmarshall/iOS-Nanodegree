//
//  hearthstone.playground
//  iOS Networking
//
//  Created by Jarrod Parkes on 09/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

/* Path for JSON files bundled with the Playground */
var pathForHearthstoneJSON = Bundle.main.path(forResource: "hearthstone", ofType: "json")

/* Raw JSON data (...simliar to the format you might receive from the network) */
var rawHearthstoneJSON = try? Data(contentsOf: URL(fileURLWithPath: pathForHearthstoneJSON!))

/* Error object */
var parsingHearthstoneError: NSError? = nil

/* Parse the data into usable form */
var parsedHearthstoneJSON = try! JSONSerialization.jsonObject(with: rawHearthstoneJSON!, options: .allowFragments) as! NSDictionary

func parseJSONAsDictionary(_ dictionary: NSDictionary) {
    /* Start playing with JSON here... */
    var cost5 = 0
    var dura2 = 0
    var batCry = 0
    var numCostForRarityItemsDictionary = [String:Int]()
    var sumCostForRarityDictionary = [String:Int]()
    /* Nifty trick: Make an array of key values to be used by the dictionaries */
    let rarities = ["Free", "Common"]
    
    /* Loop through the keys and initliaze those values to 0 */
    for rarity in rarities {
        numCostForRarityItemsDictionary[rarity] = 0
        sumCostForRarityDictionary[rarity] = 0
    }
    
    guard let cardArray = parsedHearthstoneJSON["Basic"] as? [[String: AnyObject]] else {
        print("no cardArray")
        return
    }
    
    for cards in cardArray {
        // Check if minion
        guard let cardType = cards["type"] as? String else {
            print("Cannot find key 'type' in \(cards)")
            return
        }
        
        /* Looking at a Minion card */
        if cardType == "Minion" {
            // Get attack
            guard let attack = cards["attack"] as? Int else {
                print("Cannot find key 'attack' in \(cards)")
                return
            }
            
            // Get Mana Cost
            guard let manaCost = cards["cost"] as? Int else {
                print("Cannot find key 'cost' in \(cards)")
                return
            }
            
            // Add to cost5 when card is both a minion and costs 5
            if cards["type"] as? String == "Minion" && cards["cost"] as? Int == 5 {
                cost5 += 1
                // Check for battlecry
                if let cardText = cards["text"] as? String, cardText.range(of: "Battlecry") != nil {
                    print("this minion has battlecry effect")
                }
            }
            
            // Add to dura2 when card is both a weapon and durability of 2
            if cards["type"] as? String == "Weapon" && cards["durability"] as? Int == 2 {
                dura2 += 1
            }
            
            // Get card rarity
            guard let rarityForCard = cards["rarity"] as? String else {
                print("Cannot find key 'rarityForCard' in \(cards)")
                return
            }
            
            numCostForRarityItemsDictionary[rarityForCard]! += 1
            sumCostForRarityDictionary[rarityForCard]! += manaCost
        }
        
    }
    print("cost 5:",cost5)
    print("durability 2:",dura2)
    print("battlecry:",batCry)
}

parseJSONAsDictionary(parsedHearthstoneJSON)
