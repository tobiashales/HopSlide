//
//  GameScene.swift
//  HopSlide
//
//  Created by Tobias Hales on 4/7/18.
//  Copyright © 2024 TobiasHales. All rights reserved.

// Updated by Tobias Hales on 8/21/24
//


import SpriteKit
import GameplayKit
import UIKit
import SceneKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Create Categories
    
    let orbCategory:UInt32 = 0x00000001 << 1
    let blueEnemyCategory:UInt32 = 0x00000001 << 2
    let jumperCategory:UInt32 = 0x00000001 << 3
    let redEnemyCategory:UInt32 = 0x00000001 << 4
    let groundCategory:UInt32 = 0x00000001 << 5
    let scoreCategory:UInt32 = 0x00000001 << 6
    let deleteCategory:UInt32 = 0x00000001 << 7
    
    
    // MARK: - Create Sprites
    
    var orb = SKSpriteNode(imageNamed: "orb")
    var scrollingG:scrollingGround?
    var invisibleGround = SKSpriteNode(imageNamed: "invisible")
    var enemy = SKSpriteNode(imageNamed: "blueE.png")
    var jumperBlock = SKSpriteNode(imageNamed: "invisible.png")
    var scoreBlock = SKSpriteNode(imageNamed: "invisible.png")
    var scoreLabel = SKLabelNode(text: "0")
    var deleteBlock = SKSpriteNode(imageNamed: "invisible.png")
    var greenParticleEffect = SKEmitterNode(fileNamed: "Green.sks")
    var blueSmokeEffect = SKEmitterNode(fileNamed: "blueSmoke.sks")
    var redSmokeEffect = SKEmitterNode(fileNamed: "redSmoke.sks")
    
    
    
    // MARK: - Create Integers
    
    let rotateDuration = 1.5
    var iphonexblueEnemyMoveSpeed = 4.0
     var iphonexredEnemyMoveSpeed = 4.0
    
    var blueEnemyMoveSpeed = 4.0
    var redEnemyMoveSpeed = 4.0
    
    var addEnemySpeed = 4.00
    
    // MARK: - Create Global Variables
    struct playerScore {
        static var score = 0
    }
    
    struct scrollingSpeeds {
        static var maybeIphonexgroundScrollingSpeed = 0.0
        static var maybeGroundScrollingSpeed = 0.0
    }
   
    
    //create random spawn time
    var enemies2 = arc4random_uniform(2)
    var columnTime = arc4random_uniform(4) + 2
    
    // MARK: - Create Booleans
    var orbCanJump = false
    var redEnemyCanJump = true
    var scorable = true
    var hapticable = true
  
    // MARK: - tvOS setup
    private func configureForAppleTV() {
        score = 0
        orbCanJump = false
        redEnemyCanJump = true
        scorable = true
        blueEnemyMoveSpeed = 4.2
        redEnemyMoveSpeed = 4.2
        addEnemySpeed = 4.0
        var groundScrollingSpeed = 5.5

        func createOrb(){
            let orbConst = frame.size.width/2
            let xConstraint = SKConstraint.positionX(SKRange(constantValue: orbConst))
            orb.position = CGPoint(x: frame.size.width/2, y: frame.size.height * 0.44)
            orb.size = CGSize(width: frame.size.width*0.06, height: frame.size.height*0.035)
            orb.physicsBody = SKPhysicsBody(texture: orb.texture!, size: orb.size)
            orb.constraints = [xConstraint]
            orb.name = "orb"
            orb.physicsBody?.allowsRotation = false
            orb.physicsBody?.categoryBitMask = orbCategory
            orb.physicsBody?.contactTestBitMask = blueEnemyCategory | redEnemyCategory | groundCategory
            greenParticleEffect?.position = orb.position
            greenParticleEffect?.zPosition = 2
            greenParticleEffect?.particleSpeed = 260
            greenParticleEffect?.particleSize = CGSize(width: 14, height: 14)
            self.addChild(greenParticleEffect!)
            self.addChild(orb)
        }

        func createScrollingGround () {
            scrollingG = scrollingGround.scrollingNodeWithImage(imageName: "ground", containerWidth: self.size.width)
            scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
            scrollingG?.anchorPoint = .zero
            self.addChild(scrollingG!)
        }

        func createGround(){
            invisibleGround.position = CGPoint(x: 0, y: frame.size.height * 0.26)
            invisibleGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width * 3, height: 12))
            invisibleGround.physicsBody?.isDynamic = false
            invisibleGround.name = "ground"
            invisibleGround.physicsBody?.categoryBitMask = groundCategory
            invisibleGround.physicsBody?.contactTestBitMask = orbCategory | redEnemyCategory
            self.addChild(invisibleGround)
        }

        func pickRandom() {
            enemies2 = arc4random_uniform(2)
        }

        func spawnEnemy() {
            if enemies2 == 0 {
                enemy = SKSpriteNode(imageNamed: "blueE.png")
                enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
                enemy.size = CGSize(width: frame.size.width*0.06, height: frame.size.height*0.035)
                enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                enemy.name = "blueEnemy"
                scorable = true
                enemy.physicsBody?.categoryBitMask = blueEnemyCategory
                enemy.physicsBody?.contactTestBitMask = orbCategory | scoreCategory | deleteCategory
                self.addChild(enemy)
                let moveLeft = SKAction.moveBy(x: -2000, y: 0, duration: TimeInterval(blueEnemyMoveSpeed))
                enemy.run(moveLeft)
                blueSmokeEffect?.position = enemy.position
                blueSmokeEffect?.zPosition = 2
                blueSmokeEffect?.particleSize = CGSize(width: 20, height: 20)
                self.addChild(blueSmokeEffect!)
            }
            if enemies2 == 1{
                enemy = SKSpriteNode(imageNamed: "redE.png")
                enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
                enemy.size = CGSize(width: frame.size.width*0.06, height: frame.size.height*0.035)
                enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                enemy.name = "redEnemy"
                scorable = true
                enemy.physicsBody?.categoryBitMask = redEnemyCategory
                enemy.physicsBody?.contactTestBitMask = jumperCategory | orbCategory | scoreCategory | deleteCategory
                self.addChild(enemy)
                let moveLeft = SKAction.moveBy(x: -2000, y: 0, duration: TimeInterval(redEnemyMoveSpeed))
                enemy.run(moveLeft)
                redSmokeEffect?.position = enemy.position
                redSmokeEffect?.zPosition = 2
                redSmokeEffect?.particleSize = CGSize(width: 22, height: 22)
                self.addChild(redSmokeEffect!)
            }
        }

        func startSpawning(){
            let wait = SKAction.wait(forDuration: TimeInterval(columnTime))
            let block = SKAction.run() {
                [unowned self] in
                if self.blueEnemyMoveSpeed <= 4.2 && self.blueEnemyMoveSpeed > 3.0{
                    self.columnTime = arc4random_uniform(4) + 3
                    spawnEnemy()
                    pickRandom()
                    startSpawning()
                } else {
                    self.columnTime = arc4random_uniform(3) + 2
                    spawnEnemy()
                    pickRandom()
                    startSpawning()
                }
            }
            let sequence = SKAction.sequence([wait, block])
            removeAction(forKey: "spawning")
            run(sequence, withKey: "spawning")
        }

        func rotate() {
            let rotate = SKAction.rotate(byAngle: CGFloat(M_PI * -2.55), duration: TimeInterval(rotateDuration))
            let repeatAction = SKAction.repeatForever(rotate)
            orb.run(repeatAction)
        }

        func createJumperBlock() {
            let jumpConst = frame.size.width * 0.66
            let xConstraint2 = SKConstraint.positionX(SKRange(constantValue: jumpConst))
            jumperBlock.size = CGSize(width: frame.size.width/1500, height: frame.size.height/1500)
            jumperBlock.position = CGPoint(x: frame.size.width, y: frame.size.height/4)
            jumperBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: jumperBlock.size.width, height: jumperBlock.size.height))
            jumperBlock.name = "jumperBlock"
            jumperBlock.constraints = [xConstraint2]
            jumperBlock.physicsBody?.categoryBitMask = jumperCategory
            jumperBlock.physicsBody?.contactTestBitMask = redEnemyCategory
            self.addChild(jumperBlock)
        }

        func createScoreBlock() {
            let xConstraint3 = SKConstraint.positionX(SKRange(constantValue: 0))
            scoreBlock.size = CGSize(width: frame.size.width * 0.98, height: frame.size.height/1500)
            scoreBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/4)
            scoreBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: scoreBlock.size.width, height: scoreBlock.size.height))
            scoreBlock.name = "scoreBlock"
            scoreBlock.constraints = [xConstraint3]
            scoreBlock.physicsBody?.categoryBitMask = scoreCategory
            scoreBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
            self.addChild(scoreBlock)
        }

        func createScoreLabel() {
            scoreLabel.fontName = "Futura Bold"
            scoreLabel.fontSize = 120
            scoreLabel.position = CGPoint(x: frame.size.width/2 , y: frame.size.height*0.8)
            scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            self.addChild(scoreLabel)
        }

        func speedUp() {
            if blueEnemyMoveSpeed >= 3.2 {
                blueEnemyMoveSpeed = blueEnemyMoveSpeed - 0.2
            }
            if redEnemyMoveSpeed >= 3.2 {
                redEnemyMoveSpeed = redEnemyMoveSpeed - 0.2
                groundScrollingSpeed = groundScrollingSpeed + 0.2
            }
            scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
            addEnemySpeed = addEnemySpeed - 1
        }

        func runSpeedUp() {
            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
                speedUp()
                }, SKAction.wait(forDuration: 4)])))
        }

        func createDeleteBlock() {
            let deleteConst = frame.size.width * -0.2
            let xConstraint4 = SKConstraint.positionX(SKRange(constantValue: deleteConst))
            deleteBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height)
            deleteBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/3)
            deleteBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: deleteBlock.size.width, height: deleteBlock.size.height))
            deleteBlock.physicsBody?.allowsRotation = false
            deleteBlock.name = "deleteBlock"
            deleteBlock.constraints = [xConstraint4]
            deleteBlock.physicsBody?.categoryBitMask = deleteCategory
            deleteBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
            self.addChild(deleteBlock)
        }

        createScrollingGround()
        createOrb()
        createGround()
        rotate()
        createJumperBlock()
        createScoreBlock()
        createDeleteBlock()
        createScoreLabel()
        runSpeedUp()
        startSpawning()
    }

    // MARK: - tvOS setup v2 (trimmed for TV parity)
    private func configureForAppleTVv2() {
        score = 0
        orbCanJump = false
        redEnemyCanJump = true
        scorable = true

        // Match iPhone look/feel using percentages instead of device lists
        blueEnemyMoveSpeed = 4.0
        redEnemyMoveSpeed = 4.0
        addEnemySpeed = 4.0
        var groundScrollingSpeed = 6.0

        func createOrb() {
            let xConstraint = SKConstraint.positionX(SKRange(constantValue: frame.size.width/2))
            orb.position = CGPoint(x: frame.size.width/2, y: frame.size.height * 0.38)
            orb.size = CGSize(width: frame.size.width * 0.11, height: frame.size.height * 0.058)
            orb.physicsBody = SKPhysicsBody(texture: orb.texture!, size: orb.size)
            orb.constraints = [xConstraint]
            orb.name = "orb"
            orb.physicsBody?.allowsRotation = false
            orb.physicsBody?.categoryBitMask = orbCategory
            orb.physicsBody?.contactTestBitMask = blueEnemyCategory | redEnemyCategory | groundCategory
            greenParticleEffect?.position = orb.position
            greenParticleEffect?.zPosition = 2
            greenParticleEffect?.particleSpeed = 300
            greenParticleEffect?.particleSize = CGSize(width: 18, height: 18)
            if let greenParticleEffect { addChild(greenParticleEffect) }
            addChild(orb)
        }

        func createScrollingGround() {
            scrollingG = scrollingGround.scrollingNodeWithImage(imageName: "ground", containerWidth: self.size.width)
            scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
            scrollingG?.anchorPoint = .zero
            if let scrollingG { addChild(scrollingG) }
        }

        func createGround() {
            invisibleGround.position = CGPoint(x: 0, y: frame.size.height * 0.2)
            invisibleGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width * 3, height: 12))
            invisibleGround.physicsBody?.isDynamic = false
            invisibleGround.name = "ground"
            invisibleGround.physicsBody?.categoryBitMask = groundCategory
            invisibleGround.physicsBody?.contactTestBitMask = orbCategory | redEnemyCategory
            addChild(invisibleGround)
        }

        func pickRandom() { enemies2 = arc4random_uniform(2) }

        func spawnEnemy() {
            let enemySize = CGSize(width: frame.size.width * 0.11, height: frame.size.height * 0.058)
            let startX = frame.size.width + frame.size.width/3
            let startY = invisibleGround.position.y + enemySize.height/2

            if enemies2 == 0 {
                enemy = SKSpriteNode(imageNamed: "blueE.png")
                enemy.position = CGPoint(x: startX, y: startY)
                enemy.size = enemySize
                enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                enemy.name = "blueEnemy"
                scorable = true
                enemy.physicsBody?.categoryBitMask = blueEnemyCategory
                enemy.physicsBody?.contactTestBitMask = orbCategory | scoreCategory | deleteCategory
                addChild(enemy)
                enemy.run(SKAction.moveBy(x: -2000, y: 0, duration: TimeInterval(blueEnemyMoveSpeed)))
                blueSmokeEffect?.position = enemy.position
                blueSmokeEffect?.zPosition = 2
                blueSmokeEffect?.particleSize = CGSize(width: 28, height: 28)
                if let blueSmokeEffect { addChild(blueSmokeEffect) }
            } else {
                enemy = SKSpriteNode(imageNamed: "redE.png")
                enemy.position = CGPoint(x: startX, y: startY)
                enemy.size = enemySize
                enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                enemy.name = "redEnemy"
                scorable = true
                enemy.physicsBody?.categoryBitMask = redEnemyCategory
                enemy.physicsBody?.contactTestBitMask = jumperCategory | orbCategory | scoreCategory | deleteCategory
                addChild(enemy)
                enemy.run(SKAction.moveBy(x: -2000, y: 0, duration: TimeInterval(redEnemyMoveSpeed)))
                redSmokeEffect?.position = enemy.position
                redSmokeEffect?.zPosition = 2
                redSmokeEffect?.particleSize = CGSize(width: 28, height: 28)
                if let redSmokeEffect { addChild(redSmokeEffect) }
            }
        }

        func startSpawning() {
            let wait = SKAction.wait(forDuration: TimeInterval(arc4random_uniform(3) + 3))
            let block = SKAction.run { [unowned self] in
                spawnEnemy()
                pickRandom()
                startSpawning()
            }
            let sequence = SKAction.sequence([wait, block])
            removeAction(forKey: "spawning")
            run(sequence, withKey: "spawning")
        }

        func rotate() {
            let rotate = SKAction.rotate(byAngle: CGFloat(M_PI * -2.55), duration: TimeInterval(rotateDuration))
            orb.run(SKAction.repeatForever(rotate))
        }

        func createJumperBlock() {
            let xConstraint2 = SKConstraint.positionX(SKRange(constantValue: frame.size.width * 0.72))
            jumperBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height/1200)
            jumperBlock.position = CGPoint(x: frame.size.width, y: frame.size.height/4)
            jumperBlock.physicsBody = SKPhysicsBody(rectangleOf: jumperBlock.size)
            jumperBlock.name = "jumperBlock"
            jumperBlock.constraints = [xConstraint2]
            jumperBlock.physicsBody?.categoryBitMask = jumperCategory
            jumperBlock.physicsBody?.contactTestBitMask = redEnemyCategory
            addChild(jumperBlock)
        }

        func createScoreBlock() {
            let xConstraint3 = SKConstraint.positionX(SKRange(constantValue: 0))
            scoreBlock.size = CGSize(width: frame.size.width * 0.98, height: frame.size.height/1500)
            scoreBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/4)
            scoreBlock.physicsBody = SKPhysicsBody(rectangleOf: scoreBlock.size)
            scoreBlock.name = "scoreBlock"
            scoreBlock.constraints = [xConstraint3]
            scoreBlock.physicsBody?.categoryBitMask = scoreCategory
            scoreBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
            addChild(scoreBlock)
        }

        func createScoreLabel() {
            scoreLabel.fontName = "Futura Bold"
            scoreLabel.fontSize = 120
            scoreLabel.position = CGPoint(x: frame.size.width/2 , y: frame.size.height*0.8)
            scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            addChild(scoreLabel)
        }

        func speedUp() {
            if blueEnemyMoveSpeed > 2.0 { blueEnemyMoveSpeed -= 0.15 }
            if redEnemyMoveSpeed > 2.0 {
                redEnemyMoveSpeed -= 0.15
                groundScrollingSpeed += 0.15
            }
            scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
            addEnemySpeed -= 1
        }

        func runSpeedUp() {
            run(SKAction.repeatForever(SKAction.sequence([SKAction.run { speedUp() }, SKAction.wait(forDuration: 4)])))
        }

        func createDeleteBlock() {
            let xConstraint4 = SKConstraint.positionX(SKRange(constantValue: -frame.size.width * 0.2))
            deleteBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height)
            deleteBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/3)
            deleteBlock.physicsBody = SKPhysicsBody(rectangleOf: deleteBlock.size)
            deleteBlock.physicsBody?.allowsRotation = false
            deleteBlock.name = "deleteBlock"
            deleteBlock.constraints = [xConstraint4]
            deleteBlock.physicsBody?.categoryBitMask = deleteCategory
            deleteBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
            addChild(deleteBlock)
        }

        createScrollingGround()
        createOrb()
        createGround()
        rotate()
        createJumperBlock()
        createScoreBlock()
        createDeleteBlock()
        createScoreLabel()
        runSpeedUp()
        startSpawning()
    }

    // MARK: - Move To View
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
    //reset the score onload
    func resetScore() {
        score = 0
    }

        //Define Model name
        let modelName = UIDevice.modelName
        print(frame.size.width)
        print(frame.size.height)
        
        if UIDevice.isAppleTV {
            configureForAppleTVv2()
            return
        }
        
        // MARK: - Create Scrolling Speed
        
        if UIDevice.hasProMotion {
            scrollingSpeeds.maybeIphonexgroundScrollingSpeed = 3.0
            scrollingSpeeds.maybeGroundScrollingSpeed = 3.0
            
        } else {
        
        //If no Pro Motion
            scrollingSpeeds.maybeIphonexgroundScrollingSpeed = 6.0
            scrollingSpeeds.maybeGroundScrollingSpeed = 6.0
        }
        
        //Re-Create scrolling speeds in GameScene Scope
        var iphonexgroundScrollingSpeed = scrollingSpeeds.maybeIphonexgroundScrollingSpeed
        var groundScrollingSpeed = scrollingSpeeds.maybeGroundScrollingSpeed
        
        //gamescene Change
        
        //----------------------------------------Start Gameplay Functions-------------------------------------
        
        
        
        
       
        // MARK: - iPad
        if UIDevice.isIPad {
            
            
            func createOrb(){
                let orbConst = frame.size.width/2
                let xConstraint = SKConstraint.positionX(SKRange(constantValue: orbConst))
                orb.position = CGPoint(x: frame.size.width/2, y: 480)
                orb.size = CGSize(width: frame.size.width*0.05, height: frame.size.height*0.026)
                orb.physicsBody = SKPhysicsBody(texture: orb.texture!, size: orb.size)
                orb.constraints = [xConstraint]
                orb.name = "orb"
                orb.physicsBody?.allowsRotation = false
                orb.physicsBody?.categoryBitMask = orbCategory
                orb.physicsBody?.contactTestBitMask = blueEnemyCategory | redEnemyCategory | groundCategory
                greenParticleEffect?.position = orb.position
                greenParticleEffect?.zPosition = 2
                greenParticleEffect?.particleSpeed = 200
                greenParticleEffect?.particleSize = CGSize(width: 10, height: 10)
                self.addChild(greenParticleEffect!)
                self.addChild(orb)
            }
            
            func createScrollingGround () {
                scrollingG = scrollingGround.scrollingNodeWithImage(imageName: "ground", containerWidth: self.size.width)
                scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
                scrollingG?.anchorPoint = .zero
                self.addChild(scrollingG!)
            }
            
            func createGround(){
                invisibleGround.position = CGPoint(x: 0, y: 290)
                invisibleGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width * 3, height: 10))
                invisibleGround.physicsBody?.isDynamic = false
                invisibleGround.name = "ground"
                invisibleGround.physicsBody?.categoryBitMask = groundCategory
                invisibleGround.physicsBody?.contactTestBitMask = orbCategory | redEnemyCategory
                self.addChild(invisibleGround)
                
            }
            
            func pickRandom() {
                enemies2 = arc4random_uniform(2)
            }
            
            func getRandomEnemy(fromArray array:[SKSpriteNode])->SKSpriteNode{
                return array[Int(arc4random_uniform(UInt32(array.count)))]
            }
            
            func spawnEnemy() {
                
                if enemies2 == 0 {
                    enemy = SKSpriteNode(imageNamed: "blueE.png")
                    enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
                    enemy.size = CGSize(width: frame.size.width*0.05, height: frame.size.height*0.026)
                    enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                    enemy.name = "blueEnemy"
                    scorable = true
                    enemy.physicsBody?.categoryBitMask = blueEnemyCategory
                    enemy.physicsBody?.contactTestBitMask = orbCategory | scoreCategory | deleteCategory
                    self.addChild(enemy)
                    let moveLeft = SKAction.moveBy(x: -1500, y: 0, duration: TimeInterval(blueEnemyMoveSpeed))
                    enemy.run(moveLeft)
                    blueSmokeEffect?.position = enemy.position
                    blueSmokeEffect?.zPosition = 2
                    blueSmokeEffect?.particleSize = CGSize(width: 40, height: 40)
                    self.addChild(blueSmokeEffect!)
                    
                }
                if enemies2 == 1{
                    enemy = SKSpriteNode(imageNamed: "redE.png")
                    enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
                    enemy.size = CGSize(width: frame.size.width*0.05, height: frame.size.height*0.026)
                    enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                    enemy.name = "redEnemy"
                    scorable = true
                    enemy.physicsBody?.categoryBitMask = redEnemyCategory
                    enemy.physicsBody?.contactTestBitMask = jumperCategory | orbCategory | scoreCategory | deleteCategory
                    self.addChild(enemy)
                    let moveLeft = SKAction.moveBy(x: -1500, y: 0, duration: TimeInterval(redEnemyMoveSpeed))
                    enemy.run(moveLeft)
                    redSmokeEffect?.position = enemy.position
                    redSmokeEffect?.zPosition = 2
                    redSmokeEffect?.particleSize = CGSize(width: 40, height: 40)
                    self.addChild(redSmokeEffect!)
                }
            }
            
            func startSpawning(){
                let wait = SKAction.wait(forDuration: TimeInterval(columnTime))
                let block = SKAction.run()
                {
                    [unowned self] in
                    if self.blueEnemyMoveSpeed <= 4.0 && self.blueEnemyMoveSpeed > 3.0{
                        self.columnTime = arc4random_uniform(4) + 4
                        spawnEnemy()
                        pickRandom()
                        startSpawning()
                    }else if self.blueEnemyMoveSpeed < 3.0 && self.blueEnemyMoveSpeed > 2.0 {
                        self.columnTime = arc4random_uniform(4) + 3
                        spawnEnemy()
                        pickRandom()
                        startSpawning()
                    }else if self.blueEnemyMoveSpeed < 2.0 && self.blueEnemyMoveSpeed >= 1.0{
                        self.columnTime = arc4random_uniform(4) + 2
                        spawnEnemy()
                        pickRandom()
                        startSpawning()
                    }
                }
                let sequence = SKAction.sequence([wait, block])
                removeAction(forKey: "spawning")
                run(sequence, withKey: "spawning")
            }
            
            
            func rotate() {
                let rotate = SKAction.rotate(byAngle: CGFloat(M_PI * -2.55), duration: TimeInterval(rotateDuration))
                let repeatAction = SKAction.repeatForever(rotate)
                orb.run(repeatAction)
            }
            
            func createJumperBlock() {
                let jumpConst = frame.size.width/3 + frame.size.width/3 + frame.size.width/30
                let xConstraint2 = SKConstraint.positionX(SKRange(constantValue: jumpConst))
                jumperBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height/1200)
                jumperBlock.position = CGPoint(x: frame.size.width, y: frame.size.height/4)
                jumperBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: jumperBlock.size.width, height: jumperBlock.size.height))
                jumperBlock.name = "jumperBlock"
                jumperBlock.constraints = [xConstraint2]
                jumperBlock.physicsBody?.categoryBitMask = jumperCategory
                jumperBlock.physicsBody?.contactTestBitMask = redEnemyCategory
                self.addChild(jumperBlock)
            }
            
            func createScoreBlock() {
                let xConstraint3 = SKConstraint.positionX(SKRange(constantValue: 0))
                scoreBlock.size = CGSize(width: frame.size.width * 0.98, height: frame.size.height/1200)
                scoreBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/4)
                scoreBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: scoreBlock.size.width, height: scoreBlock.size.height))
                scoreBlock.name = "scoreBlock"
                scoreBlock.constraints = [xConstraint3]
                scoreBlock.physicsBody?.categoryBitMask = scoreCategory
                scoreBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
                self.addChild(scoreBlock)
            }
            
            func createScoreLabel() {
                scoreLabel.fontName = "Futura Bold"
                scoreLabel.fontSize = 60
                scoreLabel.position = CGPoint(x: frame.size.width/2 , y: frame.size.height/2 + frame.size.height/4)
                scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
                self.addChild(scoreLabel)
            }
            
            func speedUp() {
                
                if blueEnemyMoveSpeed >= 3.0 {
                    blueEnemyMoveSpeed = blueEnemyMoveSpeed - 0.2
                }else if blueEnemyMoveSpeed <= 3.0 {
                    blueEnemyMoveSpeed = blueEnemyMoveSpeed - 0.1
                }
                
                if redEnemyMoveSpeed >= 3.0 {
                    redEnemyMoveSpeed = redEnemyMoveSpeed - 0.2
                    groundScrollingSpeed = groundScrollingSpeed + 0.2
                }
                scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
                addEnemySpeed = addEnemySpeed - 1
            }
            
            func runSpeedUp() {
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
                    speedUp()
                    }, SKAction.wait(forDuration: 4)])))
            }
            
            func createDeleteBlock() {
                let deleteConst = frame.size.width - frame.size.width - frame.size.width/6
                let xConstraint4 = SKConstraint.positionX(SKRange(constantValue: deleteConst))
                deleteBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height)
                deleteBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/3)
                deleteBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: deleteBlock.size.width, height: deleteBlock.size.height))
                deleteBlock.physicsBody?.allowsRotation = false
                deleteBlock.name = "deleteBlock"
                deleteBlock.constraints = [xConstraint4]
                deleteBlock.physicsBody?.categoryBitMask = deleteCategory
                deleteBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
                self.addChild(deleteBlock)
            }
            
            
            
            
            
            //_______________________________________Execute Funcions______________________________________________
            resetScore()
            createScrollingGround()
            createOrb()
            createGround()
            rotate()
            createJumperBlock()
            createScoreBlock()
            createDeleteBlock()
            createScoreLabel()
            runSpeedUp()
            startSpawning()
            
            
        }
        
        
        
        
        // MARK: - iPhone With Ears
        if UIDevice.isIPhoneEars {
            
            func createOrb(){
                let orbConst = frame.size.width/2
                let xConstraint = SKConstraint.positionX(SKRange(constantValue: orbConst))
                orb.position = CGPoint(x: frame.size.width/2, y: 480)
                orb.size = CGSize(width: frame.size.width*0.11, height: frame.size.height*0.0576)
                orb.physicsBody = SKPhysicsBody(texture: orb.texture!, size: orb.size)
                orb.constraints = [xConstraint]
                orb.name = "orb"
                orb.physicsBody?.allowsRotation = false
                orb.physicsBody?.categoryBitMask = orbCategory
                orb.physicsBody?.contactTestBitMask = blueEnemyCategory | redEnemyCategory | groundCategory
                greenParticleEffect?.position = orb.position
                greenParticleEffect?.zPosition = 2
                greenParticleEffect?.particleSpeed = 300
                self.addChild(greenParticleEffect!)
                self.addChild(orb)
            }
            
            func createScrollingGround () {
                scrollingG = scrollingGround.scrollingNodeWithImage(imageName: "ground", containerWidth: self.size.width)
                scrollingG?.scrollingSpeed = CGFloat(iphonexgroundScrollingSpeed)
                scrollingG?.anchorPoint = .zero
                self.addChild(scrollingG!)
            }
            
            func createGround(){
                invisibleGround.position = CGPoint(x: 0, y: 190)
                invisibleGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width * 3, height: 10))
                invisibleGround.physicsBody?.isDynamic = false
                invisibleGround.name = "ground"
                invisibleGround.physicsBody?.categoryBitMask = groundCategory
                invisibleGround.physicsBody?.contactTestBitMask = orbCategory | redEnemyCategory
                self.addChild(invisibleGround)
                
            }
            
            func pickRandom() {
                enemies2 = arc4random_uniform(2)
            }
            
            func getRandomEnemy(fromArray array:[SKSpriteNode])->SKSpriteNode{
                return array[Int(arc4random_uniform(UInt32(array.count)))]
            }
            
            func spawnEnemy() {
                
                if enemies2 == 0 {
                    enemy = SKSpriteNode(imageNamed: "blueE.png")
                    enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
                    enemy.size = CGSize(width: frame.size.width*0.11, height: frame.size.height*0.0576)
                    enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                    enemy.name = "blueEnemy"
                    scorable = true
                    enemy.physicsBody?.categoryBitMask = blueEnemyCategory
                    enemy.physicsBody?.contactTestBitMask = orbCategory | scoreCategory | deleteCategory
                    self.addChild(enemy)
                    let moveLeft = SKAction.moveBy(x: -1500, y: 0, duration: TimeInterval(iphonexblueEnemyMoveSpeed))
                    enemy.run(moveLeft)
                    blueSmokeEffect?.position = enemy.position
                    blueSmokeEffect?.zPosition = 2
                    self.addChild(blueSmokeEffect!)
                    
                }
                if enemies2 == 1{
                    enemy = SKSpriteNode(imageNamed: "redE.png")
                    enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
                    enemy.size = CGSize(width: frame.size.width*0.11, height: frame.size.height*0.0576)
                    enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                    enemy.name = "redEnemy"
                    scorable = true
                    enemy.physicsBody?.categoryBitMask = redEnemyCategory
                    enemy.physicsBody?.contactTestBitMask = jumperCategory | orbCategory | scoreCategory | deleteCategory
                    self.addChild(enemy)
                    let moveLeft = SKAction.moveBy(x: -1500, y: 0, duration: TimeInterval(iphonexredEnemyMoveSpeed))
                    enemy.run(moveLeft)
                    redSmokeEffect?.position = enemy.position
                    redSmokeEffect?.zPosition = 2
                    self.addChild(redSmokeEffect!)
                }
            }
            
            func startSpawning(){
                let wait = SKAction.wait(forDuration: TimeInterval(columnTime))
                let block = SKAction.run()
                {
                    [unowned self] in
                    if self.iphonexblueEnemyMoveSpeed <= 4.0 && self.iphonexblueEnemyMoveSpeed > 3.0{
                        self.columnTime = arc4random_uniform(4) + 4
                        spawnEnemy()
                        pickRandom()
                        startSpawning()
                    }else if self.iphonexblueEnemyMoveSpeed < 3.0 && self.iphonexblueEnemyMoveSpeed > 2.0 {
                        self.columnTime = arc4random_uniform(4) + 3
                        spawnEnemy()
                        pickRandom()
                        startSpawning()
                    }else if self.iphonexblueEnemyMoveSpeed < 2.0 && self.iphonexblueEnemyMoveSpeed >= 1.0{
                        self.columnTime = arc4random_uniform(4) + 2
                        spawnEnemy()
                        pickRandom()
                        startSpawning()
                    }
                }
                let sequence = SKAction.sequence([wait, block])
                removeAction(forKey: "spawning")
                run(sequence, withKey: "spawning")
            }
            
            
            func rotate() {
                let rotate = SKAction.rotate(byAngle: CGFloat(M_PI * -2.55), duration: TimeInterval(rotateDuration))
                let repeatAction = SKAction.repeatForever(rotate)
                orb.run(repeatAction)
            }
            
            func createJumperBlock() {
                let jumpConst = frame.size.width/3 + frame.size.width/3 + frame.size.width/30
                let xConstraint2 = SKConstraint.positionX(SKRange(constantValue: jumpConst))
                jumperBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height/1200)
                jumperBlock.position = CGPoint(x: frame.size.width, y: frame.size.height/4)
                jumperBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: jumperBlock.size.width, height: jumperBlock.size.height))
                jumperBlock.name = "jumperBlock"
                jumperBlock.constraints = [xConstraint2]
                jumperBlock.physicsBody?.categoryBitMask = jumperCategory
                jumperBlock.physicsBody?.contactTestBitMask = redEnemyCategory
                self.addChild(jumperBlock)
            }
            
            func createScoreBlock() {
                let xConstraint3 = SKConstraint.positionX(SKRange(constantValue: 0))
                scoreBlock.size = CGSize(width: frame.size.width * 0.98, height: frame.size.height/1200)
                scoreBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/4)
                scoreBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: scoreBlock.size.width, height: scoreBlock.size.height))
                scoreBlock.name = "scoreBlock"
                scoreBlock.constraints = [xConstraint3]
                scoreBlock.physicsBody?.categoryBitMask = scoreCategory
                scoreBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
                self.addChild(scoreBlock)
            }
            
            func createScoreLabel() {
                scoreLabel.fontName = "Futura Bold"
                scoreLabel.fontSize = 100
                scoreLabel.position = CGPoint(x: frame.size.width/2 , y: frame.size.height/2 + frame.size.height/3)
                scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
                self.addChild(scoreLabel)
            }
            
            func speedUp() {
                
                if iphonexblueEnemyMoveSpeed >= 3.0 {
                    iphonexblueEnemyMoveSpeed = iphonexblueEnemyMoveSpeed - 0.2
                }else if iphonexblueEnemyMoveSpeed <= 3.0 {
                    iphonexblueEnemyMoveSpeed = iphonexblueEnemyMoveSpeed - 0.1
                }
                
                if iphonexredEnemyMoveSpeed >= 3.0 {
                    iphonexredEnemyMoveSpeed = iphonexredEnemyMoveSpeed - 0.2
                    iphonexgroundScrollingSpeed = iphonexgroundScrollingSpeed + 0.2
                }
                scrollingG?.scrollingSpeed = CGFloat(iphonexgroundScrollingSpeed)
                addEnemySpeed = addEnemySpeed - 1
            }
            
            func runSpeedUp() {
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
                    speedUp()
                    }, SKAction.wait(forDuration: 4)])))
            }
            
            func createDeleteBlock() {
                let deleteConst = frame.size.width - frame.size.width - frame.size.width/6
                let xConstraint4 = SKConstraint.positionX(SKRange(constantValue: deleteConst))
                deleteBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height)
                deleteBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/3)
                deleteBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: deleteBlock.size.width, height: deleteBlock.size.height))
                deleteBlock.physicsBody?.allowsRotation = false
                deleteBlock.name = "deleteBlock"
                deleteBlock.constraints = [xConstraint4]
                deleteBlock.physicsBody?.categoryBitMask = deleteCategory
                deleteBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
                self.addChild(deleteBlock)
            }
            
            
            //_______________________________________Execute Funcions______________________________________________
            resetScore()
            createScrollingGround()
            createOrb()
            createGround()
            rotate()
            createJumperBlock()
            createScoreBlock()
            createDeleteBlock()
            createScoreLabel()
            runSpeedUp()
            startSpawning()
            
            
            
            
            
            
            
        }
        
        
        // MARK: - iPhone With No Ears
        if UIDevice.isIPhoneNoEars {
            
        
    func createOrb(){
        let orbConst = frame.size.width/2
         let xConstraint = SKConstraint.positionX(SKRange(constantValue: orbConst))
        orb.position = CGPoint(x: frame.size.width/2, y: 480)
        orb.size = CGSize(width: frame.size.width*0.11, height: frame.size.height*0.0576)
        orb.physicsBody = SKPhysicsBody(texture: orb.texture!, size: orb.size)
        orb.constraints = [xConstraint]
        orb.name = "orb"
        orb.physicsBody?.allowsRotation = false
        orb.physicsBody?.categoryBitMask = orbCategory
        orb.physicsBody?.contactTestBitMask = blueEnemyCategory | redEnemyCategory | groundCategory
        greenParticleEffect?.position = orb.position
        greenParticleEffect?.zPosition = 2
        self.addChild(greenParticleEffect!)
        self.addChild(orb)
    }
    
    func createScrollingGround () {
        scrollingG = scrollingGround.scrollingNodeWithImage(imageName: "ground", containerWidth: self.size.width)
        scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
        scrollingG?.anchorPoint = .zero
        self.addChild(scrollingG!)
    }

    func createGround(){
        invisibleGround.position = CGPoint(x: 0, y: 220)
        invisibleGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width * 3, height: 10))
        invisibleGround.physicsBody?.isDynamic = false
        invisibleGround.name = "ground"
        invisibleGround.physicsBody?.categoryBitMask = groundCategory
        invisibleGround.physicsBody?.contactTestBitMask = orbCategory | redEnemyCategory
        self.addChild(invisibleGround)

    }
        
    func pickRandom() {
        enemies2 = arc4random_uniform(2)
    }
    
    func getRandomEnemy(fromArray array:[SKSpriteNode])->SKSpriteNode{
        return array[Int(arc4random_uniform(UInt32(array.count)))]
    }
    
    func spawnEnemy() {
        
        if enemies2 == 0 {
            enemy = SKSpriteNode(imageNamed: "blueE.png")
            enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
            enemy.size = CGSize(width: frame.size.width*0.11, height: frame.size.height*0.0576)
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.name = "blueEnemy"
            scorable = true
            enemy.physicsBody?.categoryBitMask = blueEnemyCategory
            enemy.physicsBody?.contactTestBitMask = orbCategory | scoreCategory | deleteCategory
            self.addChild(enemy)
            let moveLeft = SKAction.moveBy(x: -1500, y: 0, duration: TimeInterval(blueEnemyMoveSpeed))
            enemy.run(moveLeft)
            blueSmokeEffect?.position = enemy.position
            blueSmokeEffect?.zPosition = 2
            blueSmokeEffect?.particleSize = CGSize(width: 15, height: 15)
            self.addChild(blueSmokeEffect!)
            
        }
            if enemies2 == 1{
            enemy = SKSpriteNode(imageNamed: "redE.png")
            enemy.position = CGPoint(x: frame.size.width + frame.size.width/3, y: invisibleGround.position.y + enemy.size.height/2)
            enemy.size = CGSize(width: frame.size.width*0.11, height: frame.size.height*0.0576)
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.name = "redEnemy"
            scorable = true
            enemy.physicsBody?.categoryBitMask = redEnemyCategory
            enemy.physicsBody?.contactTestBitMask = jumperCategory | orbCategory | scoreCategory | deleteCategory
            self.addChild(enemy)
            let moveLeft = SKAction.moveBy(x: -1500, y: 0, duration: TimeInterval(redEnemyMoveSpeed))
            enemy.run(moveLeft)
                redSmokeEffect?.position = enemy.position
                redSmokeEffect?.zPosition = 2
                redSmokeEffect?.particleSize = CGSize(width: 20, height: 20)
                self.addChild(redSmokeEffect!)
            }
        }
        
        func startSpawning(){
            let wait = SKAction.wait(forDuration: TimeInterval(columnTime))
            let block = SKAction.run()
            {
                [unowned self] in
                if self.blueEnemyMoveSpeed <= 4.0 && self.blueEnemyMoveSpeed > 3.0{
                    self.columnTime = arc4random_uniform(4) + 4
                    spawnEnemy()
                    pickRandom()
                    startSpawning()
                }else if self.blueEnemyMoveSpeed < 3.0 && self.blueEnemyMoveSpeed > 2.0 {
                    self.columnTime = arc4random_uniform(4) + 3
                    spawnEnemy()
                    pickRandom()
                    startSpawning()
                }else if self.blueEnemyMoveSpeed < 2.0 && self.blueEnemyMoveSpeed >= 1.0{
                    self.columnTime = arc4random_uniform(4) + 2
                    spawnEnemy()
                    pickRandom()
                    startSpawning()
                }
            }
            let sequence = SKAction.sequence([wait, block])
            removeAction(forKey: "spawning")
            run(sequence, withKey: "spawning")
        }
    
    
    func rotate() {
        let rotate = SKAction.rotate(byAngle: CGFloat(M_PI * -2.55), duration: TimeInterval(rotateDuration))
        let repeatAction = SKAction.repeatForever(rotate)
        orb.run(repeatAction)
    }
    
        func createJumperBlock() {
            let jumpConst = frame.size.width/3 + frame.size.width/3 + frame.size.width/30
            let xConstraint2 = SKConstraint.positionX(SKRange(constantValue: jumpConst))
            jumperBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height/1200)
            jumperBlock.position = CGPoint(x: frame.size.width, y: frame.size.height/4)
            jumperBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: jumperBlock.size.width, height: jumperBlock.size.height))
            jumperBlock.name = "jumperBlock"
            jumperBlock.constraints = [xConstraint2]
            jumperBlock.physicsBody?.categoryBitMask = jumperCategory
            jumperBlock.physicsBody?.contactTestBitMask = redEnemyCategory
            self.addChild(jumperBlock)
        }
        
        func createScoreBlock() {
            let xConstraint3 = SKConstraint.positionX(SKRange(constantValue: 0))
            scoreBlock.size = CGSize(width: frame.size.width * 0.98, height: frame.size.height/1200)
            scoreBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/4)
            scoreBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: scoreBlock.size.width, height: scoreBlock.size.height))
            scoreBlock.name = "scoreBlock"
            scoreBlock.constraints = [xConstraint3]
            scoreBlock.physicsBody?.categoryBitMask = scoreCategory
            scoreBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
            self.addChild(scoreBlock)
        }
        
        func createScoreLabel() {
            scoreLabel.fontName = "Futura Bold"
            scoreLabel.fontSize = 120
            scoreLabel.position = CGPoint(x: frame.size.width/2 , y: frame.size.height/2 + frame.size.height/3)
            scoreLabel.fontColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
            self.addChild(scoreLabel)
        }
        
        func speedUp() {
            
            if blueEnemyMoveSpeed >= 3.0 {
                blueEnemyMoveSpeed = blueEnemyMoveSpeed - 0.2
            }else if blueEnemyMoveSpeed <= 3.0 {
                blueEnemyMoveSpeed = blueEnemyMoveSpeed - 0.1
                }
           
            if redEnemyMoveSpeed >= 3.0 {
                redEnemyMoveSpeed = redEnemyMoveSpeed - 0.2
                groundScrollingSpeed = groundScrollingSpeed + 0.2
                }
            scrollingG?.scrollingSpeed = CGFloat(groundScrollingSpeed)
            addEnemySpeed = addEnemySpeed - 1
        }
        
        func runSpeedUp() {
            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
                speedUp()
                }, SKAction.wait(forDuration: 4)])))
        }
        
        func createDeleteBlock() {
            let deleteConst = frame.size.width - frame.size.width - frame.size.width/6
            let xConstraint4 = SKConstraint.positionX(SKRange(constantValue: deleteConst))
            deleteBlock.size = CGSize(width: frame.size.width/1200, height: frame.size.height)
            deleteBlock.position = CGPoint(x: frame.size.width/8, y: frame.size.height/3)
            deleteBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: deleteBlock.size.width, height: deleteBlock.size.height))
            deleteBlock.physicsBody?.allowsRotation = false
            deleteBlock.name = "deleteBlock"
            deleteBlock.constraints = [xConstraint4]
            deleteBlock.physicsBody?.categoryBitMask = deleteCategory
            deleteBlock.physicsBody?.contactTestBitMask = redEnemyCategory | blueEnemyCategory
            self.addChild(deleteBlock)
        }
            
          
            //_______________________________________Execute Funcions______________________________________________
            resetScore()
            createScrollingGround()
            createOrb()
            createGround()
            rotate()
            createJumperBlock()
            createScoreBlock()
            createDeleteBlock()
            createScoreLabel()
            runSpeedUp()
            startSpawning()
            
            
            
            
            
            
            
    }
        


    }
    

    
    // MARK: - Did Begin Contact
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.node?.name == "orb" && contact.bodyB.node?.name == "blueEnemy" {
            #if !os(tvOS)
            let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
            hapticFeedback.prepare()
            hapticFeedback.impactOccurred()
            #endif
 
            let transition = SKTransition.push(with: SKTransitionDirection.left, duration: 0.4)
            
            let nextScene = GameOverScene(size: (self.scene?.size)!)
            nextScene.scaleMode = SKSceneScaleMode.aspectFill
            
            self.scene?.view?.presentScene(nextScene, transition: transition)
        }
        if contact.bodyA.node?.name == "orb" && contact.bodyB.node?.name == "redEnemy"{
            #if !os(tvOS)
            let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
            hapticFeedback.prepare()
            hapticFeedback.impactOccurred()
            #endif
   
            let transition = SKTransition.push(with: SKTransitionDirection.left, duration: 0.4)
            
            let nextScene = GameOverScene(size: (self.scene?.size)!)
            nextScene.scaleMode = SKSceneScaleMode.aspectFill
            
            self.scene?.view?.presentScene(nextScene, transition: transition)
        }
        if contact.bodyA.node?.name == "orb" && contact.bodyB.node?.name == "ground"{
            orbCanJump = true
            #if !os(tvOS)
            if hapticable == true {
                let hapticFeedback = UIImpactFeedbackGenerator(style: .soft)
                hapticFeedback.prepare()
                hapticFeedback.impactOccurred()
                hapticable = false
            }
            #endif
        }
        if contact.bodyA.node?.name == "ground" && contact.bodyB.node?.name == "redEnemy"{
            redEnemyCanJump = true
            
        }
        if contact.bodyA.node?.name == "jumperBlock" && contact.bodyB.node?.name == "redEnemy" {
            if redEnemyCanJump == true{
                let modelName = UIDevice.modelName
                if UIDevice.isIPad {
                    
                    enemy.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
                    
                }
                if UIDevice.isIPhoneNoEars {
                    
                    enemy.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 220))
                    
                }
                if UIDevice.isIPhoneEars {
                    enemy.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 220))
                    
                }
                
                redEnemyCanJump = false
            }
        }
        if contact.bodyA.node?.name == "scoreBlock" && contact.bodyB.node?.name == "redEnemy" {
            
            if scorable == true{
                #if !os(tvOS)
                let hapticFeedback = UIImpactFeedbackGenerator(style: .soft)
                hapticFeedback.prepare()
                hapticFeedback.impactOccurred()
                #endif
                score += 1
                scorable = false
                scoreLabel.text = String(score)
            }
        }
        if contact.bodyA.node?.name == "scoreBlock" && contact.bodyB.node?.name == "blueEnemy" {
            if scorable == true{
                score += 1
                scorable = false
                scoreLabel.text = String(score)
            }
        }
        
        if contact.bodyA.node?.name == "deleteBlock" && contact.bodyB.node?.name == "redEnemy" {
            self.enemy.removeFromParent()
            self.redSmokeEffect?.removeFromParent()
            
        }
        if contact.bodyA.node?.name == "deleteBlock" && contact.bodyB.node?.name == "blueEnemy" {
            self.enemy.removeFromParent()
            self.blueSmokeEffect?.removeFromParent()
    
        }
 
    }
    
    // MARK: - Jump handling
    private func jumpIfPossible() {
        if orbCanJump == true {
            if UIDevice.isIPad {
                hapticable = true
                orb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
            } else if UIDevice.isIPhoneNoEars {
                hapticable = true
                orb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 220))
            } else if UIDevice.isIPhoneEars {
                hapticable = true
                orb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 220))
            } else if UIDevice.isAppleTV {
                orb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 220))
            }
            orbCanJump = false
        }
    }

    // MARK: - Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        jumpIfPossible()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select || $0.type == .playPause }) {
            jumpIfPossible()
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    // MARK: - Update Current Time
    override func update(_ currentTime: TimeInterval) {
        if orbCanJump == false {
            greenParticleEffect!.alpha = 0
        }
        if orbCanJump == true {
            greenParticleEffect!.alpha = 1
        }
        if redEnemyCanJump == false {
            redSmokeEffect!.alpha = 0
        }
        if redEnemyCanJump == true {
            redSmokeEffect!.alpha = 1
        }
        blueSmokeEffect?.position.y = enemy.position.y - enemy.size.height * 0.4
        redSmokeEffect?.position.y = enemy.position.y - enemy.size.height * 0.4
        blueSmokeEffect?.position.x = enemy.position.x + enemy.size.width * 0.5
        redSmokeEffect?.position.x = enemy.position.x + enemy.size.width * 0.5
        greenParticleEffect?.position.x = orb.position.x - orb.size.width * 0.4
        greenParticleEffect?.position.y = orb.position.y - orb.size.height * 0.45
        
        if self.scrollingG != nil {
            scrollingG?.update(currentTime: currentTime)
        }
    }
}




