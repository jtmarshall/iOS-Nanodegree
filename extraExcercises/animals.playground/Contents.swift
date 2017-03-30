//
//  animals.playground
//  iOS Networking
//
//  Created by Jarrod Parkes on 09/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

/* Path for JSON files bundled with the Playground */
var pathForAnimalsJSON = Bundle.main.path(forResource: "animals", ofType: "json")

/* Raw JSON data (...simliar to the format you might receive from the network) */
var rawAnimalsJSON = try? Data(contentsOf: URL(fileURLWithPath: pathForAnimalsJSON!))

/* Error object */
var parsingAnimalsError: NSError? = nil

/* Parse the data into usable form */
var parsedAnimalsJSON = try! JSONSerialization.jsonObject(with: rawAnimalsJSON!, options: .allowFragments) as! NSDictionary

func parseJSONAsDictionary(_ dictionary: NSDictionary) {
    /* Start playing with JSON here... */
    
    // print out number of photo objects
    if let photoDict = parsedAnimalsJSON["photos"] as? NSDictionary {
        let total = photoDict["total"]!
        print("total =",total)
        
        // print out index of interrufftion
        if let photoArray = photoDict["photo"] as? [[String: AnyObject]] {
            for (index, photo) in photoArray.enumerated() {
                guard let comment = photo["comment"] else {
                    print("no comment")
                    return
                }
                guard let content = comment["_content"] as? String else {
                    print("no content")
                    return
                }
                if content.range(of: "interrufftion") != nil {
                    print(index)
                }
                if index == 2 {
                    print("3rd photo:",photo)
                }
            }
        }
    }
    
    
    
    //print(dictionary["photos"])
}

parseJSONAsDictionary(parsedAnimalsJSON)
