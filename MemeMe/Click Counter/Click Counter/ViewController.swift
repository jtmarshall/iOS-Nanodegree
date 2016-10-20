//
//  ViewController.swift
//  Click Counter
//
//  Created by Jordan  on 10/20/16.
//  Copyright © 2016 Jordan . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var count = 0
    var label:UILabel!
    var label2:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //My Label
        var label = UILabel()
        label.frame = CGRect(x: 150, y: 150, width: 60, height: 60)
        label.text = "0"

        //My second label
        var label2 = UILabel()
        label2.frame = CGRect(x: 250, y: 150, width: 60, height: 60)
        label2.text = "0"

        self.view.addSubview(label)
        self.label = label
        //show second label
        self.view.addSubview(label2)
        self.label2 = label2
        
        //My Button
        var button = UIButton()
        button.frame = CGRect(x: 150, y: 250, width: 60, height: 60)
        button.setTitle("Inc", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        self.view.addSubview(button)
        
        button.addTarget(self, action: #selector(ViewController.incrementCount), for: UIControlEvents.touchUpInside)
        
        //Decrement Button
        var decButton = UIButton()
        decButton.frame = CGRect(x: 250, y: 250, width: 60, height: 60)
        decButton.setTitle("Dec", for: .normal)
        decButton.setTitleColor(UIColor.red, for: .normal)
        self.view.addSubview(decButton)
        
        decButton.addTarget(self, action: #selector(ViewController.decrementCount), for: UIControlEvents.touchUpInside)
    }
    
    //Increase labels
    func incrementCount(){
        self.count += 1
        self.label.text = "\(self.count)"
        self.label2.text = "\(self.count)"
        //change background to green when inc
        self.view.backgroundColor = UIColor.green
    }
    
    //Decreasing function
    func decrementCount(){
        self.count -= 1
        self.label.text = "\(self.count)"
        self.label2.text = "\(self.count)"
        //change background to purple when dec
        self.view.backgroundColor = UIColor.purple
    }

}

