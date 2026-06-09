//
//  ContentView.swift
//  HopSlideTV
//
//  Created by Tobias Hales on 4/4/26.
//  Copyright © 2026 TobiasHales. All rights reserved.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: SceneLoader.makeMenuScene())
            .ignoresSafeArea()
    }
}

// MARK: - Scene Loader
private enum SceneLoader {
    static func loadScene(named name: String) -> SKScene? {
        guard Bundle.main.url(forResource: name, withExtension: "sks") != nil,
              let scene = SKScene(fileNamed: name) else { return nil }
        scene.scaleMode = .aspectFill
        return scene
    }

    static func makeMenuScene() -> SKScene {
        if let sksScene = loadScene(named: "MenuScene") {
            return sksScene
        }
        return FallbackMenuScene(size: UIScreen.main.bounds.size)
    }

    static func makeGameScene() -> SKScene {
        if let sksScene = loadScene(named: "GameScene") {
            return sksScene
        }
        return FallbackGameScene(size: UIScreen.main.bounds.size)
    }
}

// MARK: - Fallback Menu Scene (tvOS-only)
private final class FallbackMenuScene: SKScene {
    private let titleLabel = SKLabelNode(fontNamed: "Futura-Bold")
    private let subtitleLabel = SKLabelNode(fontNamed: "Futura")
    private let promptLabel = SKLabelNode(fontNamed: "Futura")

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1)

        titleLabel.text = "Hop Slide"
        titleLabel.fontSize = size.width * 0.08
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + size.height * 0.15)
        addChild(titleLabel)

        subtitleLabel.text = "Endless jump & dodge"
        subtitleLabel.fontSize = size.width * 0.028
        subtitleLabel.fontColor = SKColor(white: 0.85, alpha: 1)
        subtitleLabel.position = CGPoint(x: frame.midX, y: frame.midY + size.height * 0.07)
        addChild(subtitleLabel)

        promptLabel.text = "Press Play/Select to start"
        promptLabel.fontSize = size.width * 0.03
        promptLabel.fontColor = SKColor(red: 0.65, green: 0.82, blue: 1.0, alpha: 1)
        promptLabel.position = CGPoint(x: frame.midX, y: frame.midY - size.height * 0.08)
        addChild(promptLabel)

        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        promptLabel.run(SKAction.repeatForever(shimmer))
    }

    private func startGame() {
        let nextScene = SceneLoader.makeGameScene()
        nextScene.scaleMode = .aspectFill
        let transition = SKTransition.push(with: .left, duration: 0.35)
        view?.presentScene(nextScene, transition: transition)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select || $0.type == .playPause }) {
            startGame()
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
}

// MARK: - Fallback Game Scene (tvOS-only)
private final class FallbackGameScene: SKScene, SKPhysicsContactDelegate {
    private enum Category {
        static let orb: UInt32 = 1 << 0
        static let ground: UInt32 = 1 << 1
        static let enemy: UInt32 = 1 << 2
        static let score: UInt32 = 1 << 3
    }

    private let orb = SKShapeNode(circleOfRadius: 26)
    private let ground = SKShapeNode(rectOf: CGSize(width: 4000, height: 24))
    private let scoreLabel = SKLabelNode(fontNamed: "Futura-Bold")
    private var canJump = false
    private var score = 0

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -18)
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor(red: 0.05, green: 0.07, blue: 0.12, alpha: 1)

        // Ground
        ground.fillColor = SKColor(red: 0.21, green: 0.25, blue: 0.32, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: frame.midX, y: frame.minY + 40)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.frame.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = Category.ground
        addChild(ground)

        // Orb
        orb.fillColor = SKColor(red: 0.45, green: 0.9, blue: 0.8, alpha: 1)
        orb.strokeColor = .clear
        orb.position = CGPoint(x: frame.width * 0.25, y: frame.midY)
        orb.physicsBody = SKPhysicsBody(circleOfRadius: 26)
        orb.physicsBody?.allowsRotation = false
        orb.physicsBody?.restitution = 0.0
        orb.physicsBody?.categoryBitMask = Category.orb
        orb.physicsBody?.contactTestBitMask = Category.ground | Category.enemy
        addChild(orb)

        // Score
        scoreLabel.fontSize = size.width * 0.04
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        scoreLabel.text = "0"
        addChild(scoreLabel)

        startSpawningEnemies()
        canJump = true
    }

    private func startSpawningEnemies() {
        let spawn = SKAction.run { [weak self] in self?.spawnEnemy() }
        let wait = SKAction.wait(forDuration: 1.4, withRange: 0.4)
        run(SKAction.repeatForever(SKAction.sequence([spawn, wait])))
    }

    private func spawnEnemy() {
        let size = CGSize(width: 48, height: 42)
        let enemy = SKShapeNode(rectOf: size, cornerRadius: 6)
        enemy.fillColor = SKColor(red: 0.95, green: 0.4, blue: 0.5, alpha: 1)
        enemy.strokeColor = .clear
        enemy.position = CGPoint(x: frame.maxX + size.width, y: ground.position.y + size.height)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = Category.enemy
        enemy.physicsBody?.contactTestBitMask = Category.orb | Category.score
        addChild(enemy)

        let move = SKAction.moveBy(x: -frame.width - size.width * 2, y: 0, duration: 3.2)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([move, remove]))
    }

    private func jump() {
        guard canJump else { return }
        orb.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        orb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 620))
        canJump = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        jump()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select || $0.type == .playPause }) {
            jump()
        } else {
            super.pressesBegan(presses, with: event)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask

        if (a == Category.orb && b == Category.ground) || (b == Category.orb && a == Category.ground) {
            canJump = true
            return
        }

        if (a == Category.orb && b == Category.enemy) || (b == Category.orb && a == Category.enemy) {
            gameOver()
            return
        }
    }

    private func gameOver() {
        removeAllActions()
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.65, height: 200), cornerRadius: 24)
        overlay.fillColor = SKColor(white: 0, alpha: 0.6)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(overlay)

        let label = SKLabelNode(fontNamed: "Futura-Bold")
        label.text = "Game Over"
        label.fontSize = size.width * 0.06
        label.position = CGPoint(x: 0, y: 30)
        overlay.addChild(label)

        let retry = SKLabelNode(fontNamed: "Futura")
        retry.text = "Press Play/Select to retry"
        retry.fontSize = size.width * 0.03
        retry.position = CGPoint(x: 0, y: -40)
        overlay.addChild(retry)

        let wait = SKAction.wait(forDuration: 0.6)
        run(wait) { [weak self] in
            self?.canJump = true
            self?.startSpawningEnemies()
        }
    }
}
