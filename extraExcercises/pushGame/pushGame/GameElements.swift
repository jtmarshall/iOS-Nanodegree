//
//  GameElements.swift
//  pushGame
//
//  Created by Jordan  on 8/1/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import SpriteKit

let ScoreKey = "FLOOP_HIGHSCORE"
let LastScore = "FLOOP_LASTSCORE"
let Muted = false

struct CollisionBitMask {
    static let Player:UInt32 = 0x00
    static let Obstacle:UInt32 = 0x01
}

// Types of obstacles
enum ObstacleType:Int {
    case Small = 0
    case Medium = 1
    case Large = 2
}

// Obstacles add up to Row Types
enum RowType:Int {
    case oneS = 0
    case oneM = 1
    case oneL = 2
    case twoS = 3
    case twoM = 4
    case threeS = 5
}

// Hide Game functions in extension for readability
extension GameScene {

    // Create players
    func addPlayer() {
        // Player Attributes
        let yBall = SKTexture(imageNamed: "yellow_ball")
        // Create player sprite from the ball texture
        player = SKSpriteNode(texture: yBall)
        player.position = CGPoint(x: self.size.width/2, y: 350)
        player.name = "PLAYER"
        player.physicsBody?.isDynamic = false
        // Physics body using texture from ball
        player.physicsBody = SKPhysicsBody(texture: yBall, size: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.categoryBitMask = CollisionBitMask.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask.Obstacle
        
        // Player 2
        player2 = SKSpriteNode(color: UIColor(red: 0.91, green: 0.81, blue: 0.30, alpha: 1), size: CGSize(width: 50, height: 50)) // Straw color player2
        player2.position = CGPoint(x: self.size.width/2, y: 350)
        player2.name = "PLAYER"
        player2.physicsBody?.isDynamic = false
        player2.physicsBody = SKPhysicsBody(rectangleOf: player2.size)
        player2.physicsBody?.categoryBitMask = CollisionBitMask.Player
        player2.physicsBody?.collisionBitMask = 0
        player2.physicsBody?.contactTestBitMask = CollisionBitMask.Obstacle
        
        // Add the players
        addChild(player)
        //addChild(player2)
        
        // Starting position for player
        initialPlayerPosition = player.position
    }
    
    // Create Obstacles
    func addObstacle(type:ObstacleType) -> SKSpriteNode {
        let obstacle = SKSpriteNode(color: UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1), size: CGSize(width: 0, height: 25)) // Cloud color for row objects
        obstacle.name = "OBSTACLE"
        obstacle.physicsBody?.isDynamic = true
        
        switch type {
        case .Small:
            obstacle.size.width = self.size.width * 0.2
            break
        case .Medium:
            obstacle.size.width = self.size.width * 0.35
            break
        case .Large:
            obstacle.size.width = self.size.width * 0.75
            break
        }
        
        obstacle.position = CGPoint(x: 0, y: self.size.height + obstacle.size.height)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.categoryBitMask = CollisionBitMask.Obstacle
        obstacle.physicsBody?.collisionBitMask = 0
        
        return obstacle
    }
    
    // Movement for obstacles
    func addMovement(obstacle:SKSpriteNode) {
        var actionArray = [SKAction]()
        
        // Append(queue) up movement actions to run
        actionArray.append(SKAction.move(to: CGPoint(x: obstacle.position.x, y: -obstacle.size.height), duration: TimeInterval(4)))
        // Delete object after running sequence
        actionArray.append(SKAction.removeFromParent())
        
        obstacle.run(SKAction.sequence(actionArray))
    }
    
    // All the row types that can be seen in game
    func addRow(type:RowType) {
        // Choose obstacle type
        switch type {
        case .oneS:
            let obst = addObstacle(type: .Small)
            // Set original position off screen
            obst.position = CGPoint(x: self.size.width / 2, y: obst.position.y)
            // Make it move
            addMovement(obstacle: obst)
            // Add it to scene
            addChild(obst)
            
            break
        case .oneM:
            let obst = addObstacle(type: .Medium)
            // Set original position off screen
            obst.position = CGPoint(x: self.size.width / 2, y: obst.position.y)
            // Make it move
            addMovement(obstacle: obst)
            // Add it to scene
            addChild(obst)
            
            break
        case .oneL:
            let obst = addObstacle(type: .Large)
            // Set original position off screen
            obst.position = CGPoint(x: self.size.width / 2, y: obst.position.y)
            // Make it move
            addMovement(obstacle: obst)
            // Add it to scene
            addChild(obst)
            
            break
        case .twoS:
            // Make two obstacles now
            let obst1 = addObstacle(type: .Small)
            let obst2 = addObstacle(type: .Small)
            
            // Set original position off screen
            obst1.position = CGPoint(x: obst1.size.width + 50, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width - 50, y: obst1.position.y)
            
            // Make it move
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            // Add it to scene
            addChild(obst1)
            addChild(obst2)
  
            break
        case .twoM:
            // Make two obstacles now
            let obst1 = addObstacle(type: .Medium)
            let obst2 = addObstacle(type: .Medium)
            
            // Set original position off screen
            obst1.position = CGPoint(x: obst1.size.width / 2 + 50, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width / 2 - 50, y: obst1.position.y)
            
            // Make it move
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            // Add it to scene
            addChild(obst1)
            addChild(obst2)
            
            break
        case .threeS:
            // Now three obstacles
            let obst1 = addObstacle(type: .Small)
            let obst2 = addObstacle(type: .Small)
            let obst3 = addObstacle(type: .Small)
            
            // Set original position off screen
            obst1.position = CGPoint(x: obst1.size.width / 2 + 50, y: obst1.position.y) // Left
            obst2.position = CGPoint(x: self.size.width - obst2.size.width / 2 - 50, y: obst1.position.y) // Right
            obst3.position = CGPoint(x: self.size.width / 2, y: obst1.position.y) // Center
            
            // Make it move
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            addMovement(obstacle: obst3)
            // Add it to scene
            addChild(obst1)
            addChild(obst2)
            addChild(obst3)
            
            break
        }
    }
    
}
