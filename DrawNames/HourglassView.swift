//
//  HourglassView.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/27/25.
//

import SwiftUI
import SpriteKit

struct HourglassView: View {
    @State private var scene: HourglassScene = {
            let scene = HourglassScene()
            scene.backgroundColor = .clear
            scene.scaleMode = .resizeFill
            return scene
        }()
    
    var body: some View {
        ZStack {
            Color(.black)
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
            
            Button("Flip!") {
                scene.setSandDamping(2.0)
                scene.flipHourglass()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.scene.setSandDamping(0.2)
                }
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    HourglassView()
}
