//
//  scrollingGround.swift
//  HopSlide
//
//  Created by Tobias Hales on 4/12/18.
//  Copyright © 2024 TobiasHales. All rights reserved.

// Updated by Tobias Hales on 8/21/24
//


import SpriteKit

class scrollingGround: SKSpriteNode {
   

    var scrollingSpeed:CGFloat = 0
    
    static func scrollingNodeWithImage (imageName image:String, containerWidth width:CGFloat) -> scrollingGround {
        let gImage = UIImage(named: "ground")
        
        let scrollNode = scrollingGround(color: UIColor.clear, size: CGSize(width: width, height: (gImage?.size.height)!))
        
        scrollNode.scrollingSpeed = 1
        
        var totalWidthNeeded:CGFloat = 0
        
        while totalWidthNeeded < width + (gImage?.size.width)! {
            let child = SKSpriteNode(imageNamed: "ground")
            child.anchorPoint = CGPoint.zero
            
            
            let modelName = UIDevice.modelName
            
            if UIDevice.isIPhoneNoEars {
                child.position = CGPoint(x: totalWidthNeeded, y: 30)
                
            }
            
            if UIDevice.isIPad {
                child.position = CGPoint(x: totalWidthNeeded, y: 100)
            }
            
            if UIDevice.isIPhoneEars {
                child.position = CGPoint(x: totalWidthNeeded, y: 0)
            }
            
            scrollNode.addChild(child)
            totalWidthNeeded += child.size.width
            
        }
        
        return scrollNode
    }
    
    func update (currentTime:TimeInterval) {
        for child in self.children {
            child.position = CGPoint(x: child.position.x - self.scrollingSpeed, y: child.position.y)
            
            if child.position.x <= -child.frame.size.width {
                let delta = child.position.x + child.frame.size.width
                child.position = CGPoint(x: child.frame.size.width * CGFloat(self.children.count - 1) + delta, y: child.position.y)
            }
        }
    }
    
    
}
