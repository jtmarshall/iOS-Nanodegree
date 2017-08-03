//
//  GameScene.swift
//  pushGame
//
//  Created by Jordan  on 8/1/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var player2: SKSpriteNode!
    var initialPlayerPosition: CGPoint!
    
    // Move the players based on how hard finger pressed (3D Touch)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let maximumPossibleForce = touch.maximumPossibleForce
            let force = touch.force
            let normalizedForce = force/maximumPossibleForce
            
            player.position.x = (self.size.width / 2) - normalizedForce * (self.size.width/2 - 25)
            player2.position.x = (self.size.width / 2) + normalizedForce * (self.size.width/2 - 25)
        }
    }
    
    // Call reset after end
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetPlayerPosition()
    }
    
    // Put players back in original position for when we reset
    func resetPlayerPosition() {
        player.position = initialPlayerPosition
        player2.position = initialPlayerPosition
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        addPlayer()
    }
    
    // Adds a random row to dropdown from top
    func addRandomRow() {
        let randomNumber = Int(arc4random_uniform(6))
        
        switch randomNumber {
        case 0:
            addRow(type: RowType(rawValue: 0)!)
            break
        case 1:
            addRow(type: RowType(rawValue: 1)!)
            break
        case 2:
            addRow(type: RowType(rawValue: 2)!)
            break
        case 3:
            addRow(type: RowType(rawValue: 3)!)
            break
        case 4:
            addRow(type: RowType(rawValue: 4)!)
            break
        case 5:
            addRow(type: RowType(rawValue: 5)!)
            break
        default:
            break
        }
    }
    
    var lastUpdateTimeInterval = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    // Check our time between updates, if its been more than half a sec then another row drops down
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: CFTimeInterval) {
        lastYieldTimeInterval += timeSinceLastUpdate
        if lastYieldTimeInterval > 0.6 {
            lastYieldTimeInterval = 0
            // Have a random row type drop
            addRandomRow()
        }
    }
    
    // Used to update time interval and send more rows down screen
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        var timeSinceLastUpdate = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        if timeSinceLastUpdate > 1 {
            timeSinceLastUpdate = 1/60
            lastUpdateTimeInterval = currentTime
        }
        
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate: timeSinceLastUpdate)
    }
    
    // Watch for contact(collision)
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "PLAYER" {
            print("GAME OVER!!!")
            // If contact invoke Game Over
            showGameOver()
        }
    }
    
    // If contact take them to Game Over Scene
    func showGameOver() {
        // Create a transition we can use to get to Game Over Scene
        let transition = SKTransition.fade(withDuration: 0.5)
        // Create new Game Over Scene
        let gameOverScene = GameOverScene(size: self.size)
        // Present the Game Over Scene
        self.view?.presentScene(gameOverScene, transition: transition)
    }
}
