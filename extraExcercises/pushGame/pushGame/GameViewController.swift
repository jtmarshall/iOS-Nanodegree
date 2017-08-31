//
//  GameViewController.swift
//  pushGame
//
//  Created by Jordan  on 8/1/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    // For Music
    var backgroundMusicPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            view.delegate = self as? SKViewDelegate
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.delegate = self as? SKSceneDelegate
                // Reference to the background music file
                let bgMusicURL = Bundle.main.url(forResource: "Deep_In_Space", withExtension: "wav")
                do {
                    try backgroundMusicPlayer = AVAudioPlayer(contentsOf: bgMusicURL!)
                } catch {
                    print("Can't play music file.")
                }
                
                // Play background music for infinite loops
                backgroundMusicPlayer.numberOfLoops = -1
                backgroundMusicPlayer.prepareToPlay()
                backgroundMusicPlayer.play()
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            //view.showsPhysics = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func presentEndGame() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "EndGameViewController") as! EndGameViewController
        
        self.navigationController?.show(controller, sender: navigationController)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
