//
//  DiceView.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/17/25.
//

import SwiftUI

struct DiceView: View {
    let id: UUID
    let value: Int
    let spin: Double
    let blur: CGFloat
    let onRoll: (UUID) -> Void
    
    @State private var roll: Roll = .init(value: Int.random(in: 1...6))
    @State private var animationAmount = 0.0
    
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        return (
            x: CGFloat(Int.random(in: 0..<2)),
            y: CGFloat(Int.random(in: 0..<2)),
            z: CGFloat(Int.random(in: 0..<2)),
        )
    }
    
    var body: some View {
        Image(systemName: "die.face.\(value).fill")
            .accessibilityLabel(Text(String(value)))
            .symbolRenderingMode(.palette)
            .font(.system(size: 70).bold())
            .foregroundStyle(.black, .white)
            .shadow(color: .black, radius: 4, x: 3, y: 3)
            .rotation3DEffect(.degrees(spin * 360.0), axis: axis)
            .blur(radius: blur)
            .onTapGesture { _ in
                onRoll(id)
            }
    }
}

#Preview {
    var vm = DiceViewModel.init(count: 1)
    let die = vm.dice.first!
    ZStack {
        Color(.gray)
        DiceView(id: die.id, value: die.value, spin: die.spin, blur: die.blur, onRoll: { _ in
            vm.rollDie(id: die.id)
        })
    }
}
