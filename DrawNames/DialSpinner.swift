//
//  Spinner.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/23/25.
//

import SwiftUI

struct DialSpinner: View {
    var segments: Int = 12
    
    var segmentAngle: Double {
        return 360.0 / Double(segments)
    }
    
    // for spinning action
    @State private var angle: Double = 0
    @State private var angularVelocity: Double = 0
    @State private var lastDragTime: Date?
    @State private var lastTranslation: CGFloat = 0
    let deceleration: Double = 0.95   // closer to 1 = longer spin
    
    func applyInertia() {
        Task {
            while abs(angularVelocity) > 0.1 {
                angle += angularVelocity * 0.016
                angularVelocity *= deceleration
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    var body: some View {
        Triangle()
            .frame(width: 50, height: 50)
            .rotationEffect(.degrees(180), anchor: .center)
        
            ZStack {
                
                Circle()
                    .fill(AngularGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple]), center: .center))
                    .stroke(Color(red: 0, green: 0, blue: 0, opacity: 0.6), lineWidth: 2)
                
                ForEach(0..<segments / 2, id: \.self) { index in
                    Rectangle()
                        .fill(.white)
                        .frame(width: .infinity, height: 5)
                        .rotationEffect(Angle(degrees: Double(index) * (360.0 / Double(segments))))
                }
                
                Circle()
                    .scale(0.25)
                    .fill(Color.white)
                    .stroke(Color(red: 0, green: 0, blue: 0, opacity: 0.6), lineWidth: 2)
                
                Circle()
                    .scale(0.20)
                    .fill(Color.white)
                    .stroke(Color(red: 0, green: 0, blue: 0, opacity: 0.3), lineWidth: 2)
                
                ForEach(1...segments, id: \.self) { index in
                    HStack {
                        Spacer()
                        Text("\(index)")
                            .font(Font.largeTitle.bold())
                            .foregroundStyle(Color.white)
                            .shadow(color: .black, radius: 2)
                            .rotation3DEffect(Angle(degrees: 90), axis: (x: 0, y: 0, z: 1))
                    }
                    .padding()
                    .rotationEffect(Angle(degrees: Double(index) * segmentAngle - segmentAngle / 2.0))
                }
            }
            .rotationEffect(.degrees(angle))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let now = Date()
                        
                        if let lastTime = lastDragTime {
                            let dt = now.timeIntervalSince(lastTime)
                            let dx = value.translation.width - lastTranslation
                            
                            angularVelocity = Double(dx / CGFloat(dt)) // degrees per second
                        }
                        
                        angle += Double(value.translation.width - lastTranslation)
                        lastTranslation = value.translation.width
                        lastDragTime = now
                    }
                    .onEnded { _ in
                        lastDragTime = nil
                        lastTranslation = 0
                        applyInertia()
                    }
            )
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    DialSpinner(segments: 12)
}
