//
//  HourglassScene.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/27/25.
//

import Foundation
import SpriteKit

class HourglassScene: SKScene {
    let hourglass: HourglassShape = HourglassShape(neckWidthRatio: 0.025, curvature: 0.01, verticalInsetRatio: 0.08, horizontalInsetRatio: 0.30)
    
    let worldNode = SKNode()
    let sandNode = SKNode()
    
    private var hourglassNode: SKNode?
    private var outlineNode: SKShapeNode?
    private var timeNode = SKLabelNode(fontNamed: "Chalkduster")
    
    private var isEmittingSand: Bool = false
    var sandTimer: Timer?
    
    // grain params
    let velocityThreshold: CGFloat = 3.0
    let settleDuration: TimeInterval = 0.25  // seconds
    let recycleY: CGFloat = 8
    var spawnYRange: ClosedRange<CGFloat> {
        return (outlineNode!.frame.midY) + 25.0...(outlineNode!.frame.midY + 50.0)
    }
    var spawnXRange: ClosedRange<CGFloat> {
        let leftWallX = outlineNode!.frame.midX - outlineNode!.frame.maxX * 0.05
        let rightWallX = outlineNode!.frame.midX + outlineNode!.frame.maxX * 0.05
        return leftWallX...rightWallX
    }
    
    var timerDuration: TimeInterval = 60
    var elapsedTime: TimeInterval = 0
    
    var recycleCutoff: TimeInterval {
        timerDuration - 10   // last ~18 seconds resolve naturally
    }
    
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
        
        timeNode = SKLabelNode(fontNamed: "Chalkduster")
        timeNode.text = String("\(timerDuration - elapsedTime) seconds")
        timeNode.horizontalAlignmentMode = .left
        timeNode.position = CGPoint(x: 16, y: 16)
        
        addChild(timeNode)
        
        preloadSand(count: 500)
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
        
        print("Touched at \(location)")        
    }
    
    override func didSimulatePhysics() {
        let dt: TimeInterval = 1.0 / 60.0
        elapsedTime += isEmittingSand ? dt : 0.0
        timeNode.text = String("\(Int(timerDuration - elapsedTime)) seconds")

        for case let grain as SandGrain in sandNode.children {

            guard let body = grain.physicsBody,
                  body.isDynamic,
                  !grain.isFrozen else { continue }

            let velocity = hypot(body.velocity.dx, body.velocity.dy)

            if velocity < velocityThreshold {
                let grainY = Float(grain.position.y)
                guard grainY < 20.0 else { continue }

                grain.restTime += dt

                if grain.restTime >= settleDuration {
                    freeze(grain)
                    recycleGrainIfNeeded(grain)
                }
            } else {
                grain.restTime = 0
            }
        }
    }
    
    func freeze(_ grain: SandGrain) {
        grain.isFrozen = true
        grain.physicsBody?.isDynamic = false
        grain.physicsBody?.velocity = .zero
        grain.physicsBody?.angularVelocity = 0
    }
    
    func wakeAllSand() {
        for case let grain as SandGrain in sandNode.children {
            grain.isFrozen = false
            grain.restTime = 0
            grain.physicsBody?.isDynamic = true
        }
    }

    func rebuildHourglass() {
        hourglassNode?.removeFromParent()
        outlineNode?.removeFromParent()
        
        let hourglassSize = CGSize(
            width: size.width * 0.8,
            height: size.height * 0.9
        )

        let initPath = hourglass.hourglassPath(in: hourglassSize, shape: hourglass)
        let path = hourglass.centeredPath(initPath)
        
        print("hourglass size: \(hourglassSize)")

        let boundary = SKNode()
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        boundary.physicsBody?.isDynamic = false
        boundary.physicsBody?.friction = 0.1
        boundary.position = .zero
        worldNode.addChild(boundary)

        let outline = SKShapeNode(path: path)
        outline.physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        outline.physicsBody?.isDynamic = false
        outline.physicsBody?.friction = 0.1
        outline.strokeColor = .white
        outline.lineWidth = 2
        outline.fillColor = .clear
        outline.position = .zero
        worldNode.addChild(outline)

        hourglassNode = boundary
        outlineNode = outline
        
        print("hourglass frame: \(outlineNode?.calculateAccumulatedFrame())")
    }
    
    func flipHourglass(duration: TimeInterval = 0.8) {
        wakeAllSand()
        startEmittingSand()
        
        let startAngle = worldNode.zRotation
        let endAngle = startAngle + .pi

        let rotate = SKAction.rotate(
            toAngle: endAngle,
            duration: duration,
            shortestUnitArc: true
        )
        rotate.timingMode = .easeInEaseOut

        worldNode.run(rotate)
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
        let y: CGFloat = size.height * 0.15
        let point = CGPoint(
            x: CGFloat.random(in: xRange),
            y: y
        )
        return point
    }
    
    func startEmittingSand(rate: Double = 120) {
        elapsedTime = 0.0
        isEmittingSand = true

        sandTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / rate, repeats: true) { _ in
            guard self.isEmittingSand else { return }
            guard self.elapsedTime < self.timerDuration else { self.stopEmittingSand(); return }
        }
    }
    
    func stopEmittingSand() {
        isEmittingSand = false
        sandTimer?.invalidate()
        sandTimer = nil
    }
    
    func recycleGrainIfNeeded(_ grain: SandGrain) {
        guard isEmittingSand else { return }
        guard elapsedTime < recycleCutoff else { return }
        guard grain.isFrozen else { return }
        guard grain.position.y < recycleY else { return }

        respawn(grain)
    }
    
    func respawn(_ grain: SandGrain) {
        grain.isFrozen = false
        grain.restTime = 0

        let x = CGFloat.random(in: spawnXRange)
        let y = CGFloat.random(in: spawnYRange)

        grain.position = CGPoint(x: x, y: y)

        grain.physicsBody?.isDynamic = true
        grain.physicsBody?.velocity = .zero
        grain.physicsBody?.angularVelocity = 0
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
            let radius = CGFloat.random(in: outlineNode!.frame.maxX * 0.015 ... outlineNode!.frame.maxX * 0.02)
            let grain = SandGrain(radius: radius)
            grain.position = bottomChamberSpawnPosition()
            sandNode.addChild(grain)
        }
    }
}
