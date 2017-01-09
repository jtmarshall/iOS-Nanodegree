//
//  MemeTableViewController.swift
//  MemeMeV1.0
//
//  Created by Jordan  on 1/9/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

class SentMemesViewController: UIViewController , UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var memeTableView: UITableView!
    
    
    var memes: [Meme] {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        memeTableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell" , for : indexPath) as! CellMemeListViewController
        let meme = self.memes[indexPath.row]
        
        // Set the name and image
        cell.memeListTitle.text = meme.top
        cell.memeListImage.image = meme.memedImage
        return cell
    }
    
    //Recommendation by the Udacity Reviewer.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.memeDetail = self.memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
}
