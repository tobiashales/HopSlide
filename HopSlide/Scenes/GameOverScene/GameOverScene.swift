//
//  GameOverScene.swift
//  HopSlide
//
//  Created by Tobias Hales on 11/1/18.
//  Copyright © 2024 TobiasHales. All rights reserved.

// Updated by Tobias Hales on 10/14/2024
//

import SpriteKit
import GameplayKit
import Foundation
import GoogleMobileAds
import GameKit

// MARK: - Create Images

// Create game over text image
let gameOverText = SKSpriteNode(imageNamed: "HopSlideGameOverText.png")

// Create menu button image
let menuButton = SKSpriteNode(imageNamed: "HopSlideMenuButton.png")

// Create retry button image
let retryButton = SKSpriteNode(imageNamed: "HopSlideRetryButton.png")

var score = GameScene.playerScore.score

// Create score text label image
let scoreText = SKSpriteNode(imageNamed: "HopSlideScoreText.png")

// Create best score text label image
let bestScoreText = SKSpriteNode(imageNamed: "HopSlideBestScoreText.png")

// Create share best score image
let shareBestScoreButton = SKSpriteNode(imageNamed: "HopSlideGameOverShareButton.pdf")

// Create score box image
let scoreBox = SKSpriteNode(imageNamed: "HopSlideScoreBox.png")

// Create score label
var scoreLabel = SKLabelNode(text: "0")

// Create best score label
var bestScoreLabel = SKLabelNode(text: "0")

// GCScore
var GCScore = 0

class GameOverScene: SKScene {
    // Keep track of active touches
    var activeTouches = [UITouch: SKSpriteNode]()
    let buttonNames: Set<String> = ["menu", "retry", "ShareBestScore"]
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let modelName = UIDevice.modelName
        
        if GameViewController.tempBestScore.temporaryBestScore <= score {
            GameViewController.tempBestScore.temporaryBestScore = score
        }
        
        //--------------------------------------------Determine High Score to send to Game Center-------------------------------------------
        
        if GameViewController.tempBestScore.temporaryBestScore >= Int(defaults.string(forKey: "highscore")!)! {
            GCScore = GameViewController.tempBestScore.temporaryBestScore
        }
        if GameViewController.tempBestScore.temporaryBestScore <= Int(defaults.string(forKey: "highscore")!)! {
            GCScore = Int(defaults.string(forKey: "highscore")!)!
        }
        
        // MARK: - iPad
        if UIDevice.isIPad {
            // Define iPad button width
            let ipadButtonWidth = frame.width * 0.22
            // Define iPad button height
            let ipadButtonHeight = frame.height * 0.03
            
            // Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            
            // Show and define game over image size
            gameOverText.position.x = frame.midX
            gameOverText.position.y = frame.size.height*0.18
            gameOverText.name = "title"
            gameOverText.size = CGSize(width: frame.width*0.4, height: frame.height*0.028)
            gameOverText.zPosition = 1
            self.addChild(gameOverText)
            
            // Show and define score image size
            scoreText.position.x = frame.size.width * -0.085
            scoreText.position.y = frame.size.height*0.1
            scoreText.name = "scoreText"
            scoreText.size = CGSize(width: frame.width*0.3, height: frame.height*0.041)
            scoreText.zPosition = 2
            self.addChild(scoreText)
            
            // Show and define best score image size
            bestScoreText.position.x = frame.size.width * 0.085
            bestScoreText.position.y = frame.size.height*0.1
            bestScoreText.name = "BestScoreText"
            bestScoreText.size = CGSize(width: frame.width*0.3, height: frame.height*0.041)
            bestScoreText.zPosition = 2
            self.addChild(bestScoreText)
            
            // Show and define score box image size
            scoreBox.position.x = frame.midX
            scoreBox.position.y = frame.size.height*0.06
            scoreBox.name = "scoreText"
            scoreBox.size = CGSize(width: frame.width*0.36, height: frame.height*0.15)
            scoreBox.zPosition = 1
            self.addChild(scoreBox)
            
            // Show and define best score share image size
            shareBestScoreButton.position.x = frame.midX
            shareBestScoreButton.position.y = frame.midY + frame.size.height * 0.01
            shareBestScoreButton.name = "ShareBestScore"
            shareBestScoreButton.size = CGSize(width: frame.width*0.07, height: frame.height*0.037)
            shareBestScoreButton.zPosition = 2
            self.addChild(shareBestScoreButton)
            
            // Show and define score label
            scoreLabel.fontName = "Futura Bold"
            scoreLabel.fontSize = 60
            scoreLabel.position = CGPoint(x: frame.size.width * -0.085 , y: frame.size.height * 0.04)
            scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            scoreLabel.zPosition = 2
            scoreLabel.text = String(score)
            self.addChild(scoreLabel)
            
            // Show and define best score label
            bestScoreLabel.fontName = "Futura Bold"
            bestScoreLabel.fontSize = 60
            bestScoreLabel.position = CGPoint(x: frame.size.width * 0.085 , y: frame.size.height * 0.04)
            bestScoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            bestScoreLabel.zPosition = 2
            if GameViewController.tempBestScore.temporaryBestScore >= Int(defaults.string(forKey: "highscore")!)! {
                bestScoreLabel.text = String(GameViewController.tempBestScore.temporaryBestScore)
            }
            if GameViewController.tempBestScore.temporaryBestScore <= Int(defaults.string(forKey: "highscore")!)! {
                bestScoreLabel.text = defaults.string(forKey: "highscore")!
            }
            self.addChild(bestScoreLabel)
            
            // Show and define menu button image size
            menuButton.position = CGPoint(x: frame.midX, y: frame.size.height * -0.06)
            menuButton.name = "menu"
            menuButton.size = CGSize(width: ipadButtonWidth, height: ipadButtonHeight)
            menuButton.zPosition = 1
            self.addChild(menuButton)
            
            // Show and define retry button image size
            retryButton.position = CGPoint(x: frame.midX, y: frame.size.height * -0.13)
            retryButton.name = "retry"
            retryButton.size = CGSize(width: ipadButtonWidth, height: ipadButtonHeight)
            retryButton.zPosition = 1
            self.addChild(retryButton)
        }
        
        // MARK: - iPhone No Ears
        if UIDevice.isIPhoneNoEars {
            let buttonWidth = frame.width*0.57
            let buttonHeight = frame.height*0.078
            
            // Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            
            // Show and define game over image size
            gameOverText.position.x = frame.midX
            gameOverText.position.y = frame.size.height*0.35
            gameOverText.name = "title"
            gameOverText.size = CGSize(width: frame.width*0.82, height: frame.height*0.061)
            gameOverText.zPosition = 1
            self.addChild(gameOverText)
            
            // Show and define score image size
            scoreText.position.x = frame.size.width * -0.17
            scoreText.position.y = frame.size.height*0.18
            scoreText.name = "scoreText"
            scoreText.size = CGSize(width: frame.width*0.6, height: frame.height*0.084)
            scoreText.zPosition = 2
            self.addChild(scoreText)
            
            // Show and define best score image size
            bestScoreText.position.x = frame.size.width * 0.17
            bestScoreText.position.y = frame.size.height*0.18
            bestScoreText.name = "BestScoreText"
            bestScoreText.size = CGSize(width: frame.width*0.6, height: frame.height*0.084)
            bestScoreText.zPosition = 2
            self.addChild(bestScoreText)
            
            // Show and define best score share image size
            shareBestScoreButton.position.x = frame.midX
            shareBestScoreButton.position.y = frame.midY + frame.size.height * 0.015
            shareBestScoreButton.name = "ShareBestScore"
            shareBestScoreButton.size = CGSize(width: frame.width*0.14, height: frame.height*0.074)
            shareBestScoreButton.zPosition = 2
            self.addChild(shareBestScoreButton)
            
            // Show and define score box image size
            scoreBox.position.x = frame.midX
            scoreBox.position.y = frame.size.height*0.11
            scoreBox.name = "scoreText"
            scoreBox.size = CGSize(width: frame.width*0.75, height: frame.height*0.28)
            scoreBox.zPosition = 1
            self.addChild(scoreBox)
            
            // Show and define score label
            scoreLabel.fontName = "Futura Bold"
            scoreLabel.fontSize = 120
            scoreLabel.position = CGPoint(x: frame.size.width * -0.17 , y: frame.size.height * 0.07)
            scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            scoreLabel.zPosition = 2
            scoreLabel.text = String(score)
            self.addChild(scoreLabel)
            
            // Show and define best score label
            bestScoreLabel.fontName = "Futura Bold"
            bestScoreLabel.fontSize = 120
            bestScoreLabel.position = CGPoint(x: frame.size.width * 0.17 , y: frame.size.height * 0.07)
            bestScoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            bestScoreLabel.zPosition = 2
            if GameViewController.tempBestScore.temporaryBestScore >= Int(defaults.string(forKey: "highscore")!)! {
                bestScoreLabel.text = String(GameViewController.tempBestScore.temporaryBestScore)
            }
            if GameViewController.tempBestScore.temporaryBestScore <= Int(defaults.string(forKey: "highscore")!)! {
                bestScoreLabel.text = defaults.string(forKey: "highscore")!
            }
            self.addChild(bestScoreLabel)
            
            // Show and define menu button image size
            menuButton.position = CGPoint(x: frame.midX, y: frame.size.height * -0.14)
            menuButton.name = "menu"
            menuButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            menuButton.zPosition = 1
            self.addChild(menuButton)
            
            // Show and define retry button image size
            retryButton.position = CGPoint(x: frame.midX, y: frame.size.height * -0.282)
            retryButton.name = "retry"
            retryButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            retryButton.zPosition = 1
            self.addChild(retryButton)
        }
        
        // MARK: - iPhone Ears
        if UIDevice.isIPhoneEars {
            let buttonWidth = frame.width*0.47
            let buttonHeight = frame.height*0.066
            
            // Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            
            // Show and define game over image size
            gameOverText.position.x = frame.midX
            gameOverText.position.y = frame.size.height*0.35
            gameOverText.name = "title"
            gameOverText.size = CGSize(width: frame.width*0.72, height: frame.height*0.054)
            gameOverText.zPosition = 1
            self.addChild(gameOverText)
            
            // Show and define score image size
            scoreText.position.x = frame.size.width * -0.15
            scoreText.position.y = frame.size.height*0.18
            scoreText.name = "scoreText"
            scoreText.size = CGSize(width: frame.width*0.56, height: frame.height*0.075)
            scoreText.zPosition = 2
            self.addChild(scoreText)
            
            // Show and define best score image size
            bestScoreText.position.x = frame.size.width * 0.15
            bestScoreText.position.y = frame.size.height*0.18
            bestScoreText.name = "BestScoreText"
            bestScoreText.size = CGSize(width: frame.width*0.56, height: frame.height*0.075)
            bestScoreText.zPosition = 2
            self.addChild(bestScoreText)
            
            // Show and define best score share image size
            shareBestScoreButton.position.x = frame.midX
            shareBestScoreButton.position.y = frame.midY
            shareBestScoreButton.name = "ShareBestScore"
            shareBestScoreButton.size = CGSize(width: frame.width*0.14, height: frame.height*0.075)
            shareBestScoreButton.zPosition = 2
            self.addChild(shareBestScoreButton)
            
            // Show and define score box image size
            scoreBox.position.x = frame.midX
            scoreBox.position.y = frame.size.height*0.11
            scoreBox.name = "scoreText"
            scoreBox.size = CGSize(width: frame.width*0.65, height: frame.height*0.30)
            scoreBox.zPosition = 1
            self.addChild(scoreBox)
            
            // Show and define score label
            scoreLabel.fontName = "Futura Bold"
            scoreLabel.fontSize = 100
            scoreLabel.position = CGPoint(x: frame.size.width * -0.15 , y: frame.size.height * 0.07)
            scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            scoreLabel.zPosition = 2
            scoreLabel.text = String(score)
            self.addChild(scoreLabel)
            
            // Show and define best score label
            bestScoreLabel.fontName = "Futura Bold"
            bestScoreLabel.fontSize = 100
            bestScoreLabel.position = CGPoint(x: frame.size.width * 0.15 , y: frame.size.height * 0.07)
            bestScoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            bestScoreLabel.zPosition = 2
            if GameViewController.tempBestScore.temporaryBestScore >= Int(defaults.string(forKey: "highscore")!)! {
                bestScoreLabel.text = String(GameViewController.tempBestScore.temporaryBestScore)
            }
            if GameViewController.tempBestScore.temporaryBestScore <= Int(defaults.string(forKey: "highscore")!)! {
                bestScoreLabel.text = defaults.string(forKey: "highscore")!
            }
            self.addChild(bestScoreLabel)
            
            // Show and define menu button image size
            menuButton.position = CGPoint(x: frame.midX, y: frame.size.height * -0.14)
            menuButton.name = "menu"
            menuButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            menuButton.zPosition = 1
            self.addChild(menuButton)
            
            // Show and define retry button image size
            retryButton.position = CGPoint(x: frame.midX, y: frame.size.height * -0.282)
            retryButton.name = "retry"
            retryButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            retryButton.zPosition = 1
            self.addChild(retryButton)
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
                    
                    if spriteNode.name == "menu" {
                        // Existing code for menu button action
                        // Report scores to leaderboard
                        if GKLocalPlayer.local.isAuthenticated {
                            let scoreReporter = GKScore(leaderboardIdentifier: "com.hopslide.leaderboard")
                            scoreReporter.value = Int64(GCScore)
                            GKScore.report([scoreReporter]) { error in
                                if let error = error {
                                    print("Error reporting score: \(error)")
                                } else {
                                    print("Score submitted")
                                }
                            }
                        }
                        
                        menuButton.color = SKColor.black
                        menuButton.colorBlendFactor = -0.5
                        
                        class MyGameScene: SKScene {
                            var gameDidFinish: (() -> Void)?
                            
                            func finishGame() {
                                self.gameDidFinish?()
                            }
                        }
                        
                        if let viewController = self.view?.window?.rootViewController as? GameViewController {
                            viewController.presentInterstitial()
                            transitionToMenuScene()
                        } else {
                            print("Ad wasn't ready")
                            transitionToMenuScene()
                        }
                        
                        func transitionToMenuScene() {
                            let transition = SKTransition.push(with: SKTransitionDirection.right, duration: 0.4)
                            let nextScene = MenuScene(size: self.size)
                            nextScene.scaleMode = .aspectFill
                            self.view?.presentScene(nextScene, transition: transition)
                        }
                        
                    } else if spriteNode.name == "retry" {
                        // Existing code for retry button action
                        retryButton.color = SKColor.black
                        retryButton.colorBlendFactor = -0.5
                        
                        if GKLocalPlayer.local.isAuthenticated {
                            let scoreReporter = GKScore(leaderboardIdentifier: "com.hopslide.leaderboard")
                            scoreReporter.value = Int64(GCScore)
                            GKScore.report([scoreReporter]) { error in
                                if let error = error {
                                    print("Error reporting score: \(error)")
                                } else {
                                    print("Score submitted")
                                }
                            }
                        }
                        
                        let transition = SKTransition.push(with: SKTransitionDirection.right, duration: 0.4)
                        let nextScene = GameScene(size: (self.scene?.size)!)
                        nextScene.scaleMode = SKSceneScaleMode.aspectFill
                        self.scene?.view?.presentScene(nextScene, transition: transition)
                        
                    } else if spriteNode.name == "ShareBestScore" {
                        // Existing code for share best score button action
                        shareBestScoreButton.color = SKColor.black
                        shareBestScoreButton.colorBlendFactor = -0.5
                        
                        let showShare = scene?.view?.window?.rootViewController
                        let activityVC = UIActivityViewController(activityItems: ["Can you beat my Score of \(defaults.string(forKey: "highscore")!) in Hop Slide?"], applicationActivities: nil)
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
}
