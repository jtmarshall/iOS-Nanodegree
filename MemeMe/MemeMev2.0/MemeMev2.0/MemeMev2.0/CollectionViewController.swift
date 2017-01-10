//
//  MemeCollectionViewController.swift
//  MemeMeV1.0
//
//  Created by Jordan  on 1/9/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit

class CollectionViewController: UICollectionViewController {
    
    //app delegate object for accessing meme array in AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var memes: [Meme]!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        //load in memes from app delegate
        let applicationDelegate = (UIApplication.shared.delegate as! AppDelegate)
        memes = applicationDelegate.memes
        
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)as! CellMemeCollectionViewController
        let meme = memes[indexPath.item]
        
        cell.topLabelCollection.text = meme.top
        cell.bottomLabelCollection.text = meme.bottom
        cell.collectionImageView.image = meme.image
        //error with cell return expression convert
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Grab the DetailVC from Storyboard
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        let memes = appDelegate.memes
        detailVC.meme = memes[indexPath.item]
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}
