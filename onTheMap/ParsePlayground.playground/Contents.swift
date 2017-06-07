//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

// this line tells the Playground to execute indefinitely
//PlaygroundPage.current.needsIndefiniteExecution = true

let urlString = "http://quotes.rest/qod.json?category=inspire"
let url = URL(string: urlString)
let request = NSMutableURLRequest(url: url!)
let session = URLSession.shared
let task = session.dataTask(with: request as URLRequest) { data, response, error in
    if error != nil { // Handle error
        return
    }
    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
}

task.resume()
