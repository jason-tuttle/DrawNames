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
    
    @State private var duration: Int = 60
    
    let durationOptions = [30: "30 Seconds", 60: "1 Minute", 180: "3 Minutes", 300: "5 Minutes"]
    
    var body: some View {
        VStack {
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                SpriteView(scene: scene, options: [.allowsTransparency])
            }
            
            Picker("Time", selection: $duration) {
                ForEach(durationOptions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    Text(value)
                }
            }
            
            
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
