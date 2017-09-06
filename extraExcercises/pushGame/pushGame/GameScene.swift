//
//  GameScene.swift
//  pushGame
//
//  Created by Jordan  on 8/1/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import SpriteKit
import GameplayKit

enum Layer: CGFloat {
    case Background
    case Foreground
    case Player
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var player2: SKSpriteNode!
    var startCount: CGFloat!
    var initialPlayerPosition: CGPoint!
    private let hudNode = HudNode() // For score display
    private var center = CGFloat() // Center of screen
    private var canMove = false
    private var moveLeft = false
    private var edgeX = CGFloat()
    // Recognizers for Swiping
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    let playa = SKSpriteNode(imageNamed: "yellow_ball")
    let kGravity: CGFloat = -1500.0
    var dt: TimeInterval = 0
    var playerVelocity = CGPoint.zero
    
    // Start when moved to GameScene
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        edgeX = self.frame.size.width // Edge of screen bounds
        center = (self.size.width / 2) // Center of screen
        startCount = 0
        // Setup HUD
        hudNode.setup(size: size)
        addChild(hudNode)
        hudNode.resetPoints()
        
        addPlayer()
        // Setup playa
        setupPlayer()
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        background.position = CGPoint(x: size.width/2, y: size.height)
        background.zPosition = Layer.Background.rawValue
        addChild(background)
    }
    
    func setupPlayer() {
        playa.position = CGPoint(x: self.size.width/2, y: 350)
        playa.zPosition = Layer.Player.rawValue
        //addChild(playa)
    }
    
    func updatePlayer() {
        // Apply Gravity
        let gravity = CGPoint(x: kGravity, y: 0)
        let gravityStep = gravity.x * CGFloat(dt)
        playerVelocity.x += gravityStep
        
        // Apply Velocity
        let velocityStep = playerVelocity.x * CGFloat(dt)
        player.position.x += velocityStep
        
        // Stop player from running off screen left
        if player.position.x - player.size.width/2 < 0 {
            player.position = CGPoint(x: 0 + player.size.width/2, y: player.position.y)
        }
        
        // Stop player from running off screen right
        if player.position.x - player.size.width/2 > edgeX {
            player.position = CGPoint(x: edgeX + player.size.width/2, y: player.position.y)
        }
    }
    
//    // Swipe Rotate
//    func rotatedView(_ sender: UIRotationGestureRecognizer) {
//        if (sender.state == .began) {
//            
//        }
//        if (sender.state == .changed) {
//            // Print out rotation amount in degrees
//            let rotateAmount = Measurement(value: Double(sender.rotation), unit: UnitAngle.radians).converted(to: .degrees).value
//            print(rotateAmount)
//            
//            player.zRotation = -sender.rotation
//        }
//        if (sender.state == .ended) {
//            
//        }
//    }
//    
//    // Swipe Right
//    func swipedRight() {
//        print("swiped Right")
//    }
//    
//    // Swipe Left
//    func swipedLeft() {
//        print("swiped Left")
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            print(location)
            print(center)
            print(edgeX)
            if location.x > center {
                // Push Right
                moveLeft = true
            } else {
                // Push Left
                moveLeft = false
            }
        }
        canMove = true
    }
    
    func move(left: Bool, player: SKNode) {
        if left {
            player.position.x -= 15
            

            // Don't let them go out of bounds left
            if player.position.x < 0 {
                player.position.x = 0 + self.size.width
            }
        } else {
            player.position.x += 15
            
            // Don't let them out of bounds on right
            if player.position.x > self.size.width {
                player.position.x = self.size.width - self.size.width
            }
        }
    }
    
    private func managePlayer() {
        if canMove {
            move(left: moveLeft, player: player)
            //move(left: moveLeft, player: player2)
        } else {
            // Gravitate back towards mid when not tapping
            if player.position.x < (center - 1) {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 40, dy: 0))
            } else if player.position.x > (center + 1) {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: -40, dy: 0))
            } else {
                // No velocity once in mid
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
            }
        }
    }
    
    // Call reset after end
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        canMove = false
        //resetPlayerPosition()
    }
    
    // Put players back in original position for when we reset
    func resetPlayerPosition() {
        player.position = initialPlayerPosition
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
    // Check our time between updates, if its been more than a sec then another row drops down
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: CFTimeInterval) {
        lastYieldTimeInterval += timeSinceLastUpdate
        if lastYieldTimeInterval > 1 {
            lastYieldTimeInterval = 0
            // Have a random row type drop
            addRandomRow()
            
            if startCount < 3 {
                startCount = startCount + 1
            } else {
                hudNode.addPoint()
            }
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
        managePlayer()
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate: timeSinceLastUpdate)
    }
    
    // Watch for contact(collision)
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "PLAYER" || contact.bodyB.node?.name == "PLAYER" {
            print("GAME OVER!!!")
            // If contact invoke Game Over
            showGameOver()
        }
    }
    
    // If contact take them to Game Over Screen
    func showGameOver() {
        hudNode.saveLastScore()
        
        // Setup ViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EndGameViewController")
        // Dismiss the current VC so we can show EndGameVC
        self.view?.window?.rootViewController?.dismiss(animated: false, completion: {
            // After dismiss show endgame screen
            appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
        })
    }
    
}
