//
//  RollDiceView.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/15/25.
//

import SwiftUI

struct Roll: Hashable {
    let value: Int
    let hold: Bool = false
    let id: UUID = UUID()
}

struct RollDiceView: View {
    let gridLayout = Array(repeating: GridItem(.flexible()), count: 3)
    @StateObject private var dvm = DiceViewModel(count: 1)
    
    @State private var diceRolls: Int = 1
    @State private var rollValues: [Roll] = [Roll(value: Int.random(in: 1...6))]
    
    private var rolledValues: [Roll] = [Roll(value: Int.random(in: 1...6))]
    
    var rows: Int {
        return dvm.dice.count / 3
    }
    var leftovers: Int {
        return dvm.dice.count % 3
    }

    func rollDice() {
        rollValues = rollValues.map { _ in Roll(value: Int.random(in: 1...6)) }
        print("Rolled:", rollValues.map { $0.value })
    }

    var body: some View {
        ZStack {
            Color.orange.opacity(0.5)
                .ignoresSafeArea()
            VStack {
                Spacer()
                
                LazyVGrid(columns: [.init(), .init(), .init()], alignment: .center, spacing: 16) {
                    ForEach(dvm.dice) { die in
                        DiceView(
                            id: die.id,
                            value: die.value,
                            spin: die.spin,
                            blur: die.blur,
                            onRoll: { _ in
                                dvm.rollDie(id: die.id)
                            }
                        )
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Die", systemImage: "minus.circle") {
                        dvm.changeDiceCount(op: DiceOpType.Remove)
                    }
                    .disabled(dvm.dice.count < 2)
                    .buttonStyle(.glass)
                    .accessibilityLabel(Text("Remove one die"))
                    
                    Button("Roll!") {
                        dvm.rollAll()
                    }
                    .buttonStyle(.glassProminent)
                    .font(Font.largeTitle.bold())
                    
                    Button("Die", systemImage: "plus.circle") {
                        dvm.changeDiceCount(op: DiceOpType.Add)
                    }
                    .accessibilityLabel(Text("Add one die"))
                    .buttonStyle(.glass)
                }
            }
            .padding()
            .backgroundStyle(.ultraThinMaterial)
        }
    }
}

#Preview {
    RollDiceView()
}
