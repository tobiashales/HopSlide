//
//  MenuScene.swift
//  HopSlide
//
//  Created by Tobias Hales on 6/23/17.
//  Copyright © 2024 TobiasHales. All rights reserved.

// Updated by Tobias Hales on 10/14/24
//

import SpriteKit
import GameplayKit
import Foundation
import StoreKit
import AVFoundation
import UserNotifications
import GameKit

// MARK: - Create Images

// Create background image
let backgroundImage = SKSpriteNode(imageNamed: "HopSlideBackground.png")

// Create title image
let title = SKSpriteNode(imageNamed: "HopSlideTitle.png")

// Create play button image
var playButton = SKSpriteNode(imageNamed: "HopSlidePlayButton.png")

// Create rate button image
let rateButton = SKSpriteNode(imageNamed: "HopSlideRateButton.png")

// Create credits button image
let creditsButton = SKSpriteNode(imageNamed: "HopSlideCreditsButton.png")

// Create leaderboard button image
let leaderBoardButton = SKSpriteNode(imageNamed: "HopSlideLeaderBoardButton.png")

// Create no ads button image
let noAdButton = SKSpriteNode(imageNamed: "HopSlideNoAdsButton.png")

// Create play pause button image
var playPause = SKSpriteNode(imageNamed: "HopSlidePlayPauseButton.png")

// Create music player
struct musicPlayer {
    static var paused = false
}
var player = AVAudioPlayer()
let path = Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3")

class MenuScene: SKScene, GKGameCenterControllerDelegate {
    var activeTouches = [UITouch: SKSpriteNode]()
    let buttonNames: Set<String> = ["play", "rate", "credits", "leaderboard", "noAd", "playPause"]
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
     
        let modelName = UIDevice.modelName
        
        print(modelName)
        print(frame.size.width)
        print(frame.size.height)
        
        //__________________________________Play Music_______________________________________
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
        } catch {
            print("Could not load file")
        }
        
        player.numberOfLoops = -1
        if musicPlayer.paused == false {
            player.play()
        }
        
        // MARK: - Apple TV
        if UIDevice.isAppleTV {
            let buttonWidth = frame.width * 0.42
            let buttonHeight = frame.height * 0.06
            
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width + 6, height: frame.height + 6)
            self.addChild(backgroundImage)
            
            title.position = CGPoint(x: frame.midX, y: frame.height * 0.28)
            title.name = "title"
            title.size = CGSize(width: frame.width * 0.6, height: frame.height * 0.16)
            title.zPosition = 1
            self.addChild(title)
            
            playButton.position = CGPoint(x: frame.midX, y: frame.height * 0.05)
            playButton.name = "play"
            playButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            playButton.zPosition = 1
            self.addChild(playButton)
            
            rateButton.position = CGPoint(x: frame.midX, y: -frame.height * 0.07)
            rateButton.name = "rate"
            rateButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            rateButton.zPosition = 1
            self.addChild(rateButton)
            
            creditsButton.position = CGPoint(x: frame.midX, y: -frame.height * 0.19)
            creditsButton.name = "credits"
            creditsButton.size = CGSize(width: frame.width * 0.14, height: buttonHeight)
            creditsButton.zPosition = 1
            self.addChild(creditsButton)
            
            leaderBoardButton.position = CGPoint(x: frame.midX, y: -frame.height * 0.29)
            leaderBoardButton.name = "leaderboard"
            leaderBoardButton.size = CGSize(width: frame.width * 0.14, height: buttonHeight)
            leaderBoardButton.zPosition = 1
            self.addChild(leaderBoardButton)
            
            noAdButton.position = CGPoint(x: frame.width * 0.22, y: -frame.height * 0.24)
            noAdButton.name = "noAd"
            noAdButton.size = CGSize(width: frame.width * 0.14, height: buttonHeight)
            noAdButton.zPosition = 1
            self.addChild(noAdButton)
            
            playPause.position = CGPoint(x: -frame.width * 0.22, y: -frame.height * 0.24)
            playPause.name = "playPause"
            playPause.size = CGSize(width: frame.width * 0.14, height: buttonHeight)
            playPause.zPosition = 1
            self.addChild(playPause)
        }

        // MARK: - iPad
        if UIDevice.isIPad {
            // Define iPad button width and height
            let ipadButtonWidth = frame.width * 0.22
            let ipadButtonHeight = frame.height * 0.03
            
            // Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            self.addChild(backgroundImage)
            
            // Show and define title image size
            title.position = CGPoint(x: frame.midX, y: frame.height*0.18)
            title.name = "title"
            title.size = CGSize(width: frame.width*0.4, height: frame.height*0.1)
            title.zPosition = 1
            self.addChild(title)
            
            // Show and define play button image size
            playButton.position = CGPoint(x: frame.midX, y: frame.height*0.059)
            playButton.name = "play"
            playButton.size = CGSize(width: ipadButtonWidth, height: ipadButtonHeight)
            playButton.zPosition = 1
            self.addChild(playButton)
            
            // Show and define rate button image size
            rateButton.position = CGPoint(x: frame.midX, y: frame.height * -0.011)
            rateButton.name = "rate"
            rateButton.size = CGSize(width: ipadButtonWidth, height: ipadButtonHeight)
            rateButton.zPosition = 1
            self.addChild(rateButton)
            
            // Show and define credits button image size
            creditsButton.position = CGPoint(x: frame.midX, y: frame.height * -0.1)
            creditsButton.name = "credits"
            creditsButton.size = CGSize(width: frame.width*0.057, height: ipadButtonHeight)
            creditsButton.zPosition = 1
            self.addChild(creditsButton)
            
            // Show and define leaderboard button image size
            leaderBoardButton.position = CGPoint(x: frame.midX, y: frame.height * -0.16)
            leaderBoardButton.name = "leaderboard"
            leaderBoardButton.size = CGSize(width: frame.width*0.057, height: ipadButtonHeight)
            leaderBoardButton.zPosition = 1
            self.addChild(leaderBoardButton)
            
            // Show and define no ads button image size
            noAdButton.position = CGPoint(x: frame.size.width*0.14, y: frame.size.height * -0.13)
            noAdButton.name = "noAd"
            noAdButton.size = CGSize(width: frame.width*0.057, height: ipadButtonHeight)
            noAdButton.zPosition = 1
            self.addChild(noAdButton)
            
            // Show and define play pause button image size
            playPause.position = CGPoint(x: frame.size.width * -0.14, y: frame.size.height * -0.13)
            playPause.name = "playPause"
            playPause.size = CGSize(width: frame.width*0.057, height: ipadButtonHeight)
            playPause.zPosition = 1
            self.addChild(playPause)
        }
        
        // MARK: - iPhone No Ears
        if UIDevice.isIPhoneNoEars {
            // Define universal button width and height
            let buttonWidth = frame.width*0.57
            let buttonHeight = frame.height*0.078
            
            // Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            self.addChild(backgroundImage)
            
            // Show and define title image size
            title.position = CGPoint(x: frame.midX, y: frame.height*0.3)
            title.name = "title"
            title.size = CGSize(width: frame.width*0.79, height: frame.height*0.2)
            title.zPosition = 1
            self.addChild(title)
            
            // Show and define play button image size
            playButton.position = CGPoint(x: frame.midX, y: frame.height*0.079)
            playButton.name = "play"
            playButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            playButton.zPosition = 1
            self.addChild(playButton)
            
            // Show and define rate button image size
            rateButton.position = CGPoint(x: frame.midX, y: frame.height * -0.061)
            rateButton.name = "rate"
            rateButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            rateButton.zPosition = 1
            self.addChild(rateButton)
            
            // Show and define credits button image size
            creditsButton.position = CGPoint(x: frame.midX, y: frame.height * -0.2)
            creditsButton.name = "credits"
            creditsButton.size = CGSize(width: frame.width*0.15, height: buttonHeight)
            creditsButton.zPosition = 1
            self.addChild(creditsButton)
             
            // Show and define leaderboard button image size
            leaderBoardButton.position = CGPoint(x: frame.midX, y: frame.height * -0.32)
            leaderBoardButton.name = "leaderboard"
            leaderBoardButton.size = CGSize(width: frame.width*0.15, height: buttonHeight)
            leaderBoardButton.zPosition = 1
            self.addChild(leaderBoardButton)
            
            // Show and define no ads button image size
            noAdButton.position = CGPoint(x: frame.size.width * 0.24, y: frame.size.height * -0.26)
            noAdButton.name = "noAd"
            noAdButton.size = CGSize(width: frame.width*0.15, height: buttonHeight)
            noAdButton.zPosition = 1
            self.addChild(noAdButton)
            
            // Show and define play pause button image size
            playPause.position = CGPoint(x: frame.size.width * -0.24, y: frame.size.height * -0.26)
            playPause.name = "playPause"
            playPause.size = CGSize(width: frame.width*0.15, height: buttonHeight)
            playPause.zPosition = 1
            self.addChild(playPause)
        }
        
        // MARK: - iPhone Ears
        if UIDevice.isIPhoneEars {
            // Define universal button width and height
            let buttonWidth = frame.width*0.47
            let buttonHeight = frame.height*0.066
            
            // Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            self.addChild(backgroundImage)
            
            // Show and define title image size
            title.position = CGPoint(x: frame.midX, y: frame.height*0.3)
            title.name = "title"
            title.size = CGSize(width: frame.width*0.7, height: frame.height*0.185)
            title.zPosition = 1
            self.addChild(title)
            
            // Show and define play button image size
            playButton.position = CGPoint(x: frame.midX, y: frame.height*0.079)
            playButton.name = "play"
            playButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            playButton.zPosition = 1
            self.addChild(playButton)
            
            // Show and define rate button image size
            rateButton.position = CGPoint(x: frame.midX, y: frame.height * -0.061)
            rateButton.name = "rate"
            rateButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            rateButton.zPosition = 1
            self.addChild(rateButton)
            
            // Show and define credits button image size
            creditsButton.position = CGPoint(x: frame.midX, y: frame.height * -0.2)
            creditsButton.name = "credits"
            creditsButton.size = CGSize(width: frame.width*0.125, height: buttonHeight)
            creditsButton.zPosition = 1
            self.addChild(creditsButton)
            
            // Show and define leaderboard button image size
            leaderBoardButton.position = CGPoint(x: frame.midX, y: frame.height * -0.32)
            leaderBoardButton.name = "leaderboard"
            leaderBoardButton.size = CGSize(width: frame.width*0.125, height: buttonHeight)
            leaderBoardButton.zPosition = 1
            self.addChild(leaderBoardButton)
            
            // Show and define no ads button image size
            noAdButton.position = CGPoint(x: frame.size.width * 0.22, y: frame.size.height * -0.26)
            noAdButton.name = "noAd"
            noAdButton.size = CGSize(width: frame.width*0.125, height: buttonHeight)
            noAdButton.zPosition = 1
            self.addChild(noAdButton)
            
            // Show and define play pause button image size
            playPause.position = CGPoint(x: frame.size.width * -0.22, y: frame.size.height * -0.26)
            playPause.name = "playPause"
            playPause.size = CGSize(width: frame.width*0.125, height: buttonHeight)
            playPause.zPosition = 1
            self.addChild(playPause)
        }
    }
    
    // MARK: - Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if let nodeName = node.name, buttonNames.contains(nodeName), let spriteNode = node as? SKSpriteNode {
                activeTouches[touch] = spriteNode
                spriteNode.color = SKColor.black
                spriteNode.colorBlendFactor = 0.5
                let scaleDownAction = SKAction.scale(to: 0.9, duration: 0.1)
                spriteNode.run(scaleDownAction, withKey: "scale")
            }
        }
    }
    
    // MARK: - Touches Moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let spriteNode = activeTouches[touch] {
                let location = touch.location(in: self)
                let node = self.atPoint(location)
                if node != spriteNode {
                    // Touch moved off the button
                    spriteNode.colorBlendFactor = -0.5
                    let scaleNormalAction = SKAction.scale(to: 1.0, duration: 0.1)
                    spriteNode.run(scaleNormalAction, withKey: "scale")
                    activeTouches.removeValue(forKey: touch)
                }
            }
        }
    }
    
    // MARK: - Touches Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let spriteNode = activeTouches[touch] {
                let location = touch.location(in: self)
                let node = self.atPoint(location)
                spriteNode.colorBlendFactor = -0.5
                if node == spriteNode {
                    // Touch ended on the button
                    let scaleUpAction = SKAction.scale(to: 1.1, duration: 0.1)
                    let scaleNormalAction = SKAction.scale(to: 1.0, duration: 0.1)
                    let scaleSequence = SKAction.sequence([scaleUpAction, scaleNormalAction])
                    spriteNode.run(scaleSequence, withKey: "scale")
                    // Perform the button's action
                    if spriteNode.name == "play" {
                        let transition = SKTransition.push(with: .left, duration: 0.4)
                        let nextScene = GameScene(size: self.size)
                        nextScene.scaleMode = .aspectFill
                        self.view?.presentScene(nextScene, transition: transition)
                    } else if spriteNode.name == "rate" {
                        if #available(iOS 10.3, *) {
                            SKStoreReviewController.requestReview()
                        }
                    } else if spriteNode.name == "credits" {
                        let transition = SKTransition.push(with: .up, duration: 0.4)
                        let nextScene = CreditsScene(size: self.size)
                        nextScene.scaleMode = .aspectFill
                        self.view?.presentScene(nextScene, transition: transition)
                    } else if spriteNode.name == "playPause" {
                        if musicPlayer.paused == true {
                            playPause.texture = SKTexture(imageNamed: "HopSlidePlayPauseButton.png")
                            playPause.name = "playPause"
                            player.play()
                            musicPlayer.paused = false
                        } else if musicPlayer.paused == false {
                            playPause.texture = SKTexture(imageNamed: "HopSlidePlayPauseButtonPaused.png")
                            playPause.name = "playPause"
                            player.pause()
                            musicPlayer.paused = true
                        }
                    } else if spriteNode.name == "leaderboard" {
                        if GKLocalPlayer.local.isAuthenticated {
                            let gcVc = GKGameCenterViewController(leaderboardID: "com.hopslide.leaderboard", playerScope: .global, timeScope: .allTime)
                            gcVc.gameCenterDelegate = self
                            let vc = self.view?.window?.rootViewController
                            vc?.present(gcVc, animated: true, completion: nil)
                        } else {
                            print("Game Center is not available. Player is not authenticated.")
                        }
                    } else if spriteNode.name == "noAd" {
                        let showShare = scene?.view?.window?.rootViewController
                        let activityVC = UIActivityViewController(activityItems: ["https://apps.apple.com/us/app/hop-slide/id1018614794"], applicationActivities: nil)
                        activityVC.popoverPresentationController?.sourceView = view
                        showShare!.present(activityVC, animated: true, completion: nil)
                    }
                } else {
                    // Touch ended elsewhere
                    let scaleNormalAction = SKAction.scale(to: 1.0, duration: 0.1)
                    spriteNode.run(scaleNormalAction, withKey: "scale")
                }
                activeTouches.removeValue(forKey: touch)
            }
        }
    }

    // MARK: - Remote button support (tvOS)
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select || $0.type == .playPause }) {
            let transition = SKTransition.push(with: .left, duration: 0.4)
            let nextScene = GameScene(size: self.size)
            nextScene.scaleMode = .aspectFill
            self.view?.presentScene(nextScene, transition: transition)
        } else {
            super.pressesEnded(presses, with: event)
        }
    }
}
