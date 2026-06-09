//
//  CreditsScene.swift
//  HopSlide
//
//  Created by Tobias Hales on 10/20/18.
//  Copyright © 2024 TobiasHales. All rights reserved.

// Updated by Tobias Hales on 8/21/24
//



import SpriteKit
import GameplayKit
import Foundation


class CreditsScene: SKScene {
    
    
    // MARK: - Create Images

    //create background image
    let backgroundImage = SKSpriteNode(imageNamed: "HopSlideBackground.png")
    
    //create logo image
    let logoImage = SKSpriteNode(imageNamed: "BTPixelsLogoCropped.png")


    
    override func didMove(to view: SKView) {
          self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        let modelName = UIDevice.modelName
        
        //---------------Show images in scene--------------------
        
        
        // MARK: - iPad
        if UIDevice.isIPad {
            
        
        
        //Show and define background image size
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
        backgroundImage.name = "backgroundImage"
        self.addChild(backgroundImage)
        
        //Show and define logo image size
        logoImage.position = CGPoint(x: frame.midX, y: frame.midY)
        logoImage.size = CGSize(width: frame.width*0.34, height: frame.height*0.18)
        logoImage.name = "backgroundImage"
        logoImage.zPosition = 1
        self.addChild(logoImage)
            
            
            
        }
        
        // MARK: - iPhone No Ears
        if UIDevice.isIPhoneNoEars {
        
        
            
            //Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            backgroundImage.name = "backgroundImage"
            self.addChild(backgroundImage)
            
            //Show and define logo image size
            logoImage.position = CGPoint(x: frame.midX, y: frame.midY)
            logoImage.size = CGSize(width: frame.width*0.74, height: frame.height*0.38)
            logoImage.name = "backgroundImage"
            logoImage.zPosition = 1
            self.addChild(logoImage)
            
            
        
        
        
        }
        
        // MARK: - iPhone Ears
        if UIDevice.isIPhoneEars {
            
            //Show and define background image size
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundImage.size = CGSize(width: frame.width+3, height: frame.height+3)
            backgroundImage.name = "backgroundImage"
            self.addChild(backgroundImage)
            
            //Show and define logo image size
            logoImage.position = CGPoint(x: frame.midX, y: frame.midY)
            logoImage.size = CGSize(width: frame.width*0.74, height: frame.height*0.38)
            logoImage.name = "backgroundImage"
            logoImage.zPosition = 1
            self.addChild(logoImage)
            
        }
 
        
    }
    
    // MARK: - Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location( in: self);
            let nodeTouch = self.atPoint(location).name;
            
            creditsButton.color = SKColor.black
            creditsButton.colorBlendFactor = -0.5
            
            if (nodeTouch == "backgroundImage" ) {
                
                let transition = SKTransition.push(with: SKTransitionDirection.down, duration: 0.4)
                
                let nextScene = MenuScene(size: (self.scene?.size)!)
                nextScene.scaleMode = SKSceneScaleMode.aspectFill
                
                self.scene?.view?.presentScene(nextScene, transition: transition)
            }
        }
    }
}

