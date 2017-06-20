//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Jordan  on 6/7/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet var studentsTable: UITableView!
    @IBOutlet weak var logout: UIBarButtonItem!
    
    var studentInformation = [[String:AnyObject]]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidAppear(_ animated: Bool) {
        studentsTable?.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        studentsTable.delegate = self
        studentsTable.dataSource = self
    }
    
    // Pin button takes you to new post
    @IBAction func pinButtonPressed(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        present(controller, animated: true, completion: nil)
    }
    
    // Logout button
    @IBAction func logout(_ sender: AnyObject) {
        
        UdacityClient.sharedInstance().deleteViewController() {(success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                // Popup alert
                let popAlert = UIAlertController(title: "Error!", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
                popAlert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                    popAlert.dismiss(animated: true, completion: nil)
                })
                self.present(popAlert, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studentInformation = StudentInfo.StudentData.studentInformation
        return studentInformation.count
    }
    // Iterate through student cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell", for: indexPath)
        let pair = self.studentInformation[(indexPath as IndexPath).row]
        // Show first and last name for each recent student
        let firstName = pair["firstName"] as! String
        let lastName = pair["lastName"] as! String
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = "\(firstName) \(lastName)"
        return cell
    }
    // Open up url in default browser
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentInformation = self.studentInformation[(indexPath as IndexPath).row]
        tableView.deselectRow(at: indexPath, animated: true)
        if let toOpen = studentInformation["mediaURL"] as? String {
            UIApplication.shared.open(NSURL(string: toOpen)! as URL, options: [:], completionHandler: nil)
        }
    }
}
