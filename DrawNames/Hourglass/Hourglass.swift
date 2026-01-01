//
//  Hourglass.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/27/25.
//

import SwiftUI

struct HourglassShape {
    // narrowest part of the neck
    var neckWidthRatio: CGFloat = 0.10
    var neckHeightRatio: CGFloat = 0.04      // length of throat
    var funnelHeightRatio: CGFloat = 0.12

    var curvature: CGFloat = 0.25
    
    // inset from screen edges
    var verticalInsetRatio: CGFloat = 0.05
    var horizontalInsetRatio: CGFloat = 0.10
    
    func hourglassPath(
        in size: CGSize,
        shape: HourglassShape
    ) -> CGPath {
        let w = size.width
        let h = size.height

        let halfW = size.width / 2
        let halfH = size.height / 2
        
        let hInset = w * shape.horizontalInsetRatio
        let vInset = h * shape.verticalInsetRatio

        let topY = h - vInset
        let bottomY = vInset
        let midY = h / 2

        let maxX = w - hInset
        let minX = hInset

        let neckHalfWidth = (w * shape.neckWidthRatio) / 2

        let throatTopY = shape.neckHeightRatio * halfH
        let throatBottomY = -throatTopY
        let funnelHeight = size.height * shape.funnelHeightRatio

        let leftNeckX = halfW - neckHalfWidth
        let rightNeckX = halfW + neckHalfWidth

        let controlOffset = w * shape.curvature

        let path = CGMutablePath()

        // Top left
        path.move(to: CGPoint(x: minX, y: topY))

       // Upper funnel (left)
        path.addCurve(
            to: CGPoint(x: -neckHalfWidth, y: throatTopY),
            control1: CGPoint(x: minX, y: throatTopY + funnelHeight),
            control2: CGPoint(x: -neckHalfWidth - funnelHeight, y: throatTopY)
        )

        // Throat (left wall)
        path.addLine(to: CGPoint(x: -neckHalfWidth, y: throatBottomY))

        // Lower funnel (left)
        path.addCurve(
            to: CGPoint(x: minX, y: bottomY),
            control1: CGPoint(x: -neckHalfWidth - funnelHeight, y: throatBottomY),
            control2: CGPoint(x: minX, y: throatBottomY - funnelHeight)
        )

        // Left wall, neck → bottom
        path.addCurve(
            to: CGPoint(x: minX, y: bottomY),
            control1: CGPoint(x: leftNeckX - controlOffset, y: midY),
            control2: CGPoint(x: minX, y: midY - controlOffset)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: maxX, y: bottomY))

       // Upper funnel (right)
        path.addCurve(
            to: CGPoint(x: neckHalfWidth, y: throatTopY),
            control1: CGPoint(x: minX, y: throatTopY + funnelHeight),
            control2: CGPoint(x: neckHalfWidth - funnelHeight, y: throatTopY)
        )

        // Throat (right wall)
        path.addLine(to: CGPoint(x: neckHalfWidth, y: throatBottomY))

        // Lower funnel (right)
        path.addCurve(
            to: CGPoint(x: minX, y: bottomY),
            control1: CGPoint(x: neckHalfWidth - funnelHeight, y: throatBottomY),
            control2: CGPoint(x: minX, y: throatBottomY - funnelHeight)
        )

        // Right wall, neck → top
        path.addCurve(
            to: CGPoint(x: maxX, y: topY),
            control1: CGPoint(x: rightNeckX + controlOffset, y: midY),
            control2: CGPoint(x: maxX, y: midY + controlOffset)
        )

        path.closeSubpath()
        return path
    }
    
    func centeredPath(_ path: CGPath) -> CGPath {
        let bounds = path.boundingBox
        var transform = CGAffineTransform(
            translationX: -bounds.midX,
            y: -bounds.midY
        )
        return path.copy(using: &transform) ?? path
    }
}

struct Hourglass: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    Hourglass()
}
