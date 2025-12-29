//
//  HourglassScene.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/27/25.
//

import Foundation
import SpriteKit

class HourglassScene: SKScene {
    let hourglass: HourglassShape = HourglassShape()
    
    let worldNode = SKNode()
    
    private var hourglassNode: SKNode?
    private var outlineNode: SKShapeNode?
    
    func gravityVector(for angle: CGFloat, magnitude: CGFloat) -> CGVector {
        CGVector(
            dx: sin(angle) * magnitude,
            dy: -cos(angle) * magnitude
        )
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundColor = .clear

//        worldNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(worldNode)
        rebuildHourglass()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
//        worldNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        rebuildHourglass()
    }
    
    func rebuildHourglass() {
        hourglassNode?.removeFromParent()
        outlineNode?.removeFromParent()

        let path = hourglass.hourglassPath(in: size, shape: hourglass)

        // Physics boundary
        let boundary = SKNode()
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        boundary.physicsBody?.isDynamic = false
        boundary.physicsBody?.friction = 0.6
        worldNode.addChild(boundary)

        // Visual outline (optional)
        let outline = SKShapeNode(path: path)
        outline.strokeColor = .white
        outline.lineWidth = 2
        outline.fillColor = .clear
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

        // Animate gravity in sync
        let gravityMagnitude = physicsWorld.gravity.dy.magnitude

        let steps = 60
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let angle = startAngle + (.pi * t)

            DispatchQueue.main.asyncAfter(
                deadline: .now() + duration * Double(t)
            ) {
                self.physicsWorld.gravity =
                    self.gravityVector(for: angle, magnitude: gravityMagnitude)
            }
        }
    }
    
    func setSandDamping(_ value: CGFloat) {
        worldNode.children
            .compactMap { $0.physicsBody }
            .forEach {
                $0.linearDamping = value
                $0.angularDamping = value
            }
    }
}
