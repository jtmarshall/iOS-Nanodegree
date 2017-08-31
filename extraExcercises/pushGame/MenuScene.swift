//
//  MenuScene.swift
//  pushGame
//
//  Created by Jordan  on 8/4/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import FBSDKLoginKit

class MenuScene: SKScene {
    let startButtonTexture = SKTexture(imageNamed: "button_start")
    let startButtonPressedTexture = SKTexture(imageNamed: "button_start_pressed")
    let soundButtonTexture = SKTexture(imageNamed: "speaker_on")
    let soundButtonTextureOff = SKTexture(imageNamed: "speaker_off")
    
    //let logoSprite = SKSpriteNode(imageNamed: "logo")
    var startButton : SKSpriteNode! = nil
    var soundButton : SKSpriteNode! = nil
    
    let highScoreNode = SKLabelNode(fontNamed: "MarkerFelt-Thin")
    
    var selectedButton : SKSpriteNode?
    
    override func sceneDidLoad() {
        backgroundColor = SKColor(red: 0.20, green: 0.19, blue: 0.20, alpha: 1)
        
        // Facebook Login
        let loginButton = FBSDKLoginButton()
        view?.addSubview(loginButton)
        // Bottom Center display for login button
        loginButton.frame = CGRect(x: 32, y: size.height - 140, width: size.width - 64, height: 50)
        
        //Set up start button
        startButton = SKSpriteNode(texture: startButtonTexture)
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - startButton.size.height / 2)
        
        addChild(startButton)
        
        let edgeMargin : CGFloat = 25
        
        //Set up sound button
        soundButton = SKSpriteNode(texture: soundButtonTexture)
        soundButton.position = CGPoint(x: size.width - soundButton.size.width / 2 - edgeMargin, y: soundButton.size.height / 2 + edgeMargin)
        
        addChild(soundButton)
    }
    
    // Button handling touch life cycle
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if any currently selected buttons
        if let touch = touches.first {
            // If so then reset those other buttons to "unpressed" form
            if selectedButton != nil {
                handleStartButtonHover(isHovering: false)
                handleSoundButtonHover(isHovering: false)
            }
            
            // Check if buttons clicked, if they are then highlight and set selectedButton
            if startButton.contains(touch.location(in: self)) {
                selectedButton = startButton
                handleStartButtonHover(isHovering: true)
            } else if soundButton.contains(touch.location(in: self)) {
                selectedButton = soundButton
                handleSoundButtonHover(isHovering: true)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            // Check which button is currently clicked
            if selectedButton == startButton {
                handleStartButtonHover(isHovering: (startButton.contains(touch.location(in: self))))
            } else if selectedButton == soundButton {
                handleSoundButtonHover(isHovering: (soundButton.contains(touch.location(in: self))))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Check button, again
            if selectedButton == startButton {
                // Start button hit
                handleStartButtonHover(isHovering: false)
                
                if (startButton.contains(touch.location(in: self))) {
                    // If still in Start button when finger leaves screen
                    handleStartButtonClick()
                }
                
            } else if selectedButton == soundButton {
                // Sound button hit
                handleSoundButtonHover(isHovering: false)
                
                if (soundButton.contains(touch.location(in: self))) {
                    // If still in Sound button when finger leaves screen
                    handleSoundButtonClick()
                }
            }
        }
        
        selectedButton = nil
    }
    
    // Handles start button hover behavior
    func handleStartButtonHover(isHovering : Bool) {
        if isHovering {
            startButton.texture = startButtonPressedTexture
        } else {
            startButton.texture = startButtonTexture
        }
    }
    
    // Handles sound button hover behavior
    func handleSoundButtonHover(isHovering : Bool) {
        if isHovering {
            soundButton.alpha = 0.5
        } else {
            soundButton.alpha = 1.0
        }
    }
    
    // Show GameScene when start button is hit
    func handleStartButtonClick() {
        let transition = SKTransition.reveal(with: .down, duration: 0.75)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        view?.presentScene(gameScene, transition: transition)
    }
    
    // Stubbed out sound button on click method
    func handleSoundButtonClick() {
        print("pressed mute")
    }

}
