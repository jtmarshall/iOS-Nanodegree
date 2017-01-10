//
//  MemeTableViewController.swift
//  MemeMeV1.0
//
//  Created by Jordan  on 1/9/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

class SentMemesViewController: UITableViewController {
    //app delegate object for accessing meme array in AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // adding edit button programmatically
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of rows
        let memes = appDelegate.memes
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memes = appDelegate.memes
        //if we dont store identifier as a variable the app crashes
        let reuseIdentifier = "ListCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CellMemeListViewController
        cell.listImageView.image = memes[indexPath.item].image
        cell.topLabelList.text = memes[indexPath.item].top
        cell.bottomLabelList.text = memes[indexPath.item].bottom
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //set data to pass to detail view
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        let memes = appDelegate.memes
        detailVC.meme = memes[indexPath.row]
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
}
