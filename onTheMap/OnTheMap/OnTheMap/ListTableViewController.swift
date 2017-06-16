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
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet var studentsTable: UITableView!
    
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
    
    @IBAction func pinButtonPressed(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        present(controller, animated: true, completion: nil)
    }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studentInformation = StudentInformation.StudentData.studentInformation
        return studentInformation.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell", for: indexPath)
        let pair = self.studentInformation[(indexPath as IndexPath).row]
        let firstName = pair["firstName"] as! String
        let lastName = pair["lastName"] as! String
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = "\(firstName) \(lastName)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentInformation = self.studentInformation[(indexPath as IndexPath).row]
        if let toOpen = studentInformation["mediaURL"] as? String {
            UIApplication.shared.open(NSURL(string: toOpen)! as URL, options: [:], completionHandler: nil)
        }
    }
}
