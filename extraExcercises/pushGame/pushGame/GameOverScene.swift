//
//  GameOverScene.swift
//  pushGame
//
//  Created by Jordan  on 8/3/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor(red: 0.20, green: 0.19, blue: 0.20, alpha: 1) // Charcoal Background
        let message = "GAME OVER!!!"
        
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = message
        label.fontColor = UIColor(red: 0.91, green: 0.77, blue: 0.80, alpha: 1) // Pink Dead Text
        label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
