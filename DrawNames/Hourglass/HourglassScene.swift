//
//  HourglassScene.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/27/25.
//

import Foundation
import SpriteKit

class HourglassScene: SKScene {
//    let hourglass: HourglassShape = HourglassShape(neckWidthRatio: 0.05, curvature: 0.01, verticalInsetRatio: 0.05, horizontalInsetRatio: 0.30)
    let hourglass: HourglassShape = HourglassShape()
    
    let worldNode = SKNode()
    let sandNode = SKNode()
    
    private var hourglassNode: SKNode?
    private var outlineNode: SKShapeNode?
    
    private var isEmittingSand: Bool = false
    var sandTimer: Timer?
    
    func gravityVector(for angle: CGFloat, magnitude: CGFloat) -> CGVector {
        CGVector(
            dx: sin(angle) * magnitude,
            dy: -cos(angle) * magnitude
        )
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundColor = .clear

        worldNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)

        addChild(worldNode)
        
        worldNode.addChild(sandNode)

        rebuildHourglass()
        
//        preloadSand(count: 300)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        worldNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        rebuildHourglass()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let radius = CGFloat.random(in: 1.2...1.6)
        let grain = SandGrain(radius: radius)
        
        grain.position = location
        sandNode.addChild(grain)
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        cleanupSand()
//    }
//    
    func rebuildHourglass() {
        hourglassNode?.removeFromParent()
        outlineNode?.removeFromParent()
        
        let hourglassSize = CGSize(
            width: size.width * 0.8,
            height: size.height * 0.9
        )

        let initPath = hourglass.hourglassPath(in: hourglassSize, shape: hourglass)
        let path = hourglass.centeredPath(initPath)

        // Physics boundary
        let boundary = SKNode()
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        boundary.physicsBody?.isDynamic = false
        boundary.physicsBody?.friction = 0.6
        boundary.position = .zero
        worldNode.addChild(boundary)

        // Visual outline (optional)
        let outline = SKShapeNode(path: path)
        outline.strokeColor = .white
        outline.lineWidth = 2
        outline.fillColor = .clear
        boundary.position = .zero
        worldNode.addChild(outline)

        hourglassNode = boundary
        outlineNode = outline
    }
    
    func flipHourglass(duration: TimeInterval = 0.8) {
        let startAngle = worldNode.zRotation
        let endAngle = startAngle + .pi

        let rotate = SKAction.rotate(
            toAngle: endAngle,
            duration: duration,
            shortestUnitArc: true
        )
        rotate.timingMode = .easeInEaseOut

        worldNode.run(rotate)
//
//        // Animate gravity in sync
//        let gravityMagnitude = physicsWorld.gravity.dy.magnitude
//
//        let steps = 60
//        for i in 0...steps {
//            let t = CGFloat(i) / CGFloat(steps)
//            let angle = startAngle + (.pi * t)
//
//            DispatchQueue.main.asyncAfter(
//                deadline: .now() + duration * Double(t)
//            ) {
//                self.physicsWorld.gravity =
//                    self.gravityVector(for: angle, magnitude: gravityMagnitude)
//            }
//        }
    }
    
    func setSandDamping(_ value: CGFloat) {
        worldNode.children
            .compactMap { $0.physicsBody }
            .forEach {
                $0.linearDamping = value
                $0.angularDamping = value
            }
    }
    
    func sandSpawnPosition() -> CGPoint {
        let xRange: ClosedRange<CGFloat> = -20...20
        let y: CGFloat = size.height * 0.35
        let point = CGPoint(
            x: CGFloat.random(in: xRange),
            y: y
        )
        print("spawning at \(point)")
        return point
    }
    
    func startEmittingSand(rate: Double = 120) {
        isEmittingSand = true

        sandTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / rate, repeats: true) { _ in
            guard self.isEmittingSand else { return }
            self.spawnSandGrain()
        }
    }
    
    func stopEmittingSand() {
        isEmittingSand = false
        sandTimer?.invalidate()
        sandTimer = nil
    }
    
    func spawnSandGrain() {
        guard sandNode.children.count < 1200 else { return }
        
        let radius = CGFloat.random(in: 8.0...10.0)
        let grain = SandGrain(radius: radius)
        
        grain.position = sandSpawnPosition()
        sandNode.addChild(grain)
    }
    
    func cleanupSand() {
        sandNode.children.compactMap { $0 as? SandGrain }
            .filter { $0.position.y > -size.height * 0.45 }
            .forEach { $0.removeFromParent() }
    }
    
    func bottomChamberSpawnPosition() -> CGPoint {
        let x = CGFloat.random(in: -30...30)
        let y = CGFloat.random(in: -size.height * 0.35 ... -size.height * 0.15)
        return CGPoint(x: x, y: y)
    }
    
    func preloadSand(count: Int = 800) {
        sandNode.removeAllChildren()

        for _ in 0..<count {
            let radius = CGFloat.random(in: 2.0...2.6)
            let grain = SandGrain(radius: radius)
            grain.position = bottomChamberSpawnPosition()
            sandNode.addChild(grain)
        }
        
        print("created \(sandNode.children.count) sand grains")
    }
}
