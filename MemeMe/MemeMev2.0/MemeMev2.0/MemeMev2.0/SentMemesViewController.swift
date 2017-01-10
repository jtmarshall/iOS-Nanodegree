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
        self.navigationItem.leftBarButtonItem = editButtonItem
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let memes = appDelegate.memes
        
        return memes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let memes = appDelegate.memes
        let reuseIdentifier = "ListCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CellMemeListViewController
        cell.listImageView.image = memes[indexPath.item].image
        cell.topLabelList.text = memes[indexPath.item].top
        cell.bottomLabelList.text = memes[indexPath.item].bottom
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        let memes = appDelegate.memes
        detailVC.meme = memes[indexPath.row]
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // allow users to delete the memes
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        appDelegate.memes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
    }
    
    // allow users to allow move the memes
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempoMeme = appDelegate.memes[sourceIndexPath.row]
        appDelegate.memes.remove(at: sourceIndexPath.row)
        appDelegate.memes.insert(tempoMeme, at: destinationIndexPath.row)
    }
    
}
