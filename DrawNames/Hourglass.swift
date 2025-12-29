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

        let controlOffset = w * shape.curvature

        let path = CGMutablePath()

        // Top left
        path.move(to: CGPoint(x: minX, y: topY))

        // Left wall, top → neck
        path.addCurve(
            to: CGPoint(x: leftNeckX, y: midY),
            control1: CGPoint(x: minX, y: midY + controlOffset),
            control2: CGPoint(x: leftNeckX - controlOffset, y: midY)
        )

        // Left wall, neck → bottom
        path.addCurve(
            to: CGPoint(x: minX, y: bottomY),
            control1: CGPoint(x: leftNeckX - controlOffset, y: midY),
            control2: CGPoint(x: minX, y: midY - controlOffset)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: maxX, y: bottomY))

        // Right wall, bottom → neck
        path.addCurve(
            to: CGPoint(x: rightNeckX, y: midY),
            control1: CGPoint(x: maxX, y: midY - controlOffset),
            control2: CGPoint(x: rightNeckX + controlOffset, y: midY)
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
}

struct Hourglass: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    Hourglass()
}
