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
    var neckHeightRatio: CGFloat = 0.02      // length of throat
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

        let hInset = w * shape.horizontalInsetRatio
        let vInset = h * shape.verticalInsetRatio

        let topY = h - vInset
        let bottomY = vInset
        let midY = h / 2

        let maxX = w - hInset
        let minX = hInset

        let neckHalfWidth = (w * shape.neckWidthRatio) / 2
        let leftNeckX = (w / 2) - neckHalfWidth
        let rightNeckX = (w / 2) + neckHalfWidth

        let throatHalfHeight = (h * shape.neckHeightRatio) / 2
        let throatTopY = midY + throatHalfHeight
        let throatBottomY = midY - throatHalfHeight

        let funnelHeight = h * shape.funnelHeightRatio
        let controlOffset = w * shape.curvature

        let path = CGMutablePath()

        // ───────────────
        // TOP LEFT START
        // ───────────────
        path.move(to: CGPoint(x: minX, y: topY))

        // ───────────────
        // LEFT WALL: top → upper funnel
        // ───────────────
        path.addCurve(
            to: CGPoint(x: leftNeckX, y: throatTopY),
            control1: CGPoint(x: minX, y: throatTopY + funnelHeight),
            control2: CGPoint(x: leftNeckX - controlOffset, y: throatTopY)
        )

        // ───────────────
        // LEFT WALL: vertical throat
        // ───────────────
        path.addLine(to: CGPoint(x: leftNeckX, y: throatBottomY))

        // ───────────────
        // LEFT WALL: lower funnel → bottom
        // ───────────────
        path.addCurve(
            to: CGPoint(x: minX, y: bottomY),
            control1: CGPoint(x: leftNeckX - controlOffset, y: throatBottomY),
            control2: CGPoint(x: minX, y: throatBottomY - funnelHeight)
        )

        // ───────────────
        // BOTTOM EDGE
        // ───────────────
        path.addLine(to: CGPoint(x: maxX, y: bottomY))

        // ───────────────
        // RIGHT WALL: bottom → lower funnel
        // ───────────────
        path.addCurve(
            to: CGPoint(x: rightNeckX, y: throatBottomY),
            control1: CGPoint(x: maxX, y: throatBottomY - funnelHeight),
            control2: CGPoint(x: rightNeckX + controlOffset, y: throatBottomY)
        )

        // ───────────────
        // RIGHT WALL: vertical throat
        // ───────────────
        path.addLine(to: CGPoint(x: rightNeckX, y: throatTopY))

        // ───────────────
        // RIGHT WALL: upper funnel → top
        // ───────────────
        path.addCurve(
            to: CGPoint(x: maxX, y: topY),
            control1: CGPoint(x: rightNeckX + controlOffset, y: throatTopY),
            control2: CGPoint(x: maxX, y: throatTopY + funnelHeight)
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
