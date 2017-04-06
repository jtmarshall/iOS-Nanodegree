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
}

public typealias HTTPHeaders = [String: String]

func tester() {
    let config = URLSessionConfiguration.default // Session Configuration
    let session = URLSession(configuration: config) // Load configuration into Session
    let url = URL(string: "https://omgvamp-hearthstone-v1.p.mashape.com/cards")!
    
    var request = URLRequest(url: URL(string: "https://omgvamp-hearthstone-v1.p.mashape.com/cards")!)
    request.addValue("X-Mashape-Key \(xsaxg89C9QmshN6Iq6AintijTIJBp1ifm7cjsnvuXCfjmFcyAY)", forHTTPHeaderField: "Authorization")
    
    let headers: HTTPHeaders = [
        "X-Mashape-Key": "xsaxg89C9QmshN6Iq6AintijTIJBp1ifm7cjsnvuXCfjmFcyAY",
        "Accept": "application/json"
    ]
    // NSDictionary; *headers = @{@"X-Mashape-Key";: @"xsaxg89C9QmshN6Iq6AintijTIJBp1ifm7cjsnvuXCfjmFcyAY"}

    
    let task = session.dataTask(with: url, completionHandler: {
        (data, response, error) in
        
        if error != nil {
            
            print(error!.localizedDescription)
            
        } else {
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                {
                    
                    //Implement your logic
                    print(json)
                    
                }
                
            } catch {
                
                print("error in JSONSerialization")
                
            }
            
            
        }
        
    })
    task.resume()
}


parseJSONAsDictionary(parsedAnimalsJSON)
