//
//  SandGrain.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/29/25.
//

import Foundation
import SpriteKit

final class SandGrain: SKShapeNode {
    init(radius: CGFloat) {
        super.init()
        
        let diameter = radius * 2
        
        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: diameter, height: diameter), transform: nil)
        fillColor = .yellow
        strokeColor = .clear
        isAntialiased = false
        
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.mass = radius * 0.002
        physicsBody?.friction = 0.3
        physicsBody?.restitution = 0.05
        physicsBody?.linearDamping = 0.25
        physicsBody?.angularDamping = 0.25
        physicsBody?.allowsRotation = true
        physicsBody?.usesPreciseCollisionDetection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
