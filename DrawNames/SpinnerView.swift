//
//  SpinnerView.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/20/25.
//

import SwiftUI

struct Wedge: InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = true
    var insetAmount = 0.0
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }

    func path(in rect: CGRect) -> Path {
        let radius = Double.minimum(rect.width, rect.height)
        print(radius)
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment
        
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.height - insetAmount,
            startAngle: modifiedStart,
            endAngle: modifiedEnd, clockwise: !clockwise
        )
        path.closeSubpath()

        return path
    }
}

struct SpinnerView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]

    @State private var sections: Int = 12
    
    @State private var hueValue: Double = 0.0

    // for spinning action
    @State private var angle: Double = 0
    @State private var angularVelocity: Double = 0
    @State private var lastDragTime: Date?
    @State private var lastTranslation: CGFloat = 0
    let deceleration: Double = 0.95   // closer to 1 = longer spin


    var wedgeAngle: Double { 360.0 / Double(sections) }
    
    func wedgeHue(index: Int) -> Double {
        return Double(index) / Double(sections);
    }
    func wedgeColor(index: Int) -> Color {
        return Color(hue: wedgeHue(index: index), saturation: 1.0, brightness: 1.0)
    }
    
    func labelPoint(_ index: Int, radius: Double = 95) -> CGSize {
        let angle = Double(index) * wedgeAngle + wedgeAngle / 2.0 - 90
        let rads = angle / 180.0 * Double.pi
        
        let x = radius * 1.75 * cos(rads);
        let y = radius * 1.75 * sin(rads);

        return CGSize(width: x, height: y)
    }
    
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
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.gradient, lineWidth: 8)
                    .scaleEffect(2)
                    .offset(x: 0, y: 95)

                Group {
                    ForEach(0..<sections, id: \.self) { number in
                        Wedge(startAngle: Angle.degrees(0), endAngle: Angle.degrees(wedgeAngle))
                            .strokeBorder(.white, lineWidth: 5)
                            .fill(wedgeColor(index: number).gradient)
                            .rotationEffect(Angle.degrees(Double(number) * wedgeAngle), anchor: .bottom)
                    }
                }

                Group {
                    ForEach(0..<sections, id: \.self) { number in
                        Text("\(number + 1)")
                            .font(.largeTitle.bold())
                            .scaleEffect(1.2)
                            .foregroundStyle(.white)
                            .rotationEffect(Angle.degrees(Double(number) * wedgeAngle + wedgeAngle / 2), anchor: .center)
                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                            .offset(labelPoint(number))
                            
                    }
                }
                .offset(x: 0, y: 95)
                
                Circle()
                    .fill(.white)
                    .stroke(Color.black, lineWidth: 3)
                    .frame(width: 100, height: 100)
                    .offset(x: 0, y: 95)

                Circle()
                    .fill(.white)
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(width: 90, height: 100)
                    .offset(x: 0, y: 95)
            }
            .padding(.horizontal)
            .containerRelativeFrame(.vertical, count: 4, spacing: 0)
            .offset(x: 0.0, y: -95.0)
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
        }
    }
}

#Preview {
    SpinnerView()
        
}
