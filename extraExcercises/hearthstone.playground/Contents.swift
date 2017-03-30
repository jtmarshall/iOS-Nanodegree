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
    guard let cardArray = parsedHearthstoneJSON["Basic"] as? [[String: AnyObject]] else {
        print("no cardArray")
        return
    }
    
    var cost5 = 0
    var dura2 = 0
    var batCry = 0
    
    for cards in cardArray {
        // add to cost5 when card is both a minion and costs 5
        if cards["type"] as? String == "Minion" && cards["cost"] as? Int == 5 {
            cost5 += 1
            // check for battlecry
            guard let mechs = cards["mechanics"] as? String else {
                return
            }
            if mechs.range(of: "Battlecry") != nil {
                    batCry += 1
            }

        }
        
        // add to dura2 when card is both a weapon and durability of 2
        if cards["type"] as? String == "Weapon" && cards["durability"] as? Int == 2 {
            dura2 += 1
        }
        
        
        
    }
    print("cost 5:",cost5)
    print("durability 2:",dura2)
    print("battlecry:",batCry)
}

parseJSONAsDictionary(parsedHearthstoneJSON)
