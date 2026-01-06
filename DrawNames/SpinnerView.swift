//
//  SpinnerView.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/20/25.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

struct SpinnerView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
    let SegmentOptions = [2, 4, 6, 12, 20]

    @State private var sections: Int = 12
    
    var body: some View {
        Text("Swipe left or right to spin!")
                .foregroundStyle(.primary)

        Spacer()
        
        DialSpinner(segments: sections)
            .padding(.horizontal)
        
        Spacer()
        
        Text("Choose the number of spaces on the spinner:")
        Picker("Segments", selection: $sections) {
            ForEach(SegmentOptions, id: \.self) { option in
                Text("\(option)")
            }
        }
        .pickerStyle(.segmented)
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    SpinnerView()
        
}
