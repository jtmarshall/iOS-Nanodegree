//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var studentInformation = [[String: AnyObject]]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidAppear(_ animated: Bool) {
        tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studentInformation = StudentInformation.student.studentInformation
        return studentInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let match = self.studentInformation[(indexPath as IndexPath).row]
        let firstName = match["firstName"] as! String
        let lastName = match["lastName"] as! String
        cell.textLabel!.text = "\(firstName) \(lastName)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let app = UIApplication.shared
        let studentInformation = self.studentInformation[(indexPath as IndexPath).row]
        if let toOpen = studentInformation["mediaURL"] as? String {
            app.openURL(URL(string: toOpen)!)
        }
    }
}
