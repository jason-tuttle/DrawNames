//
//  Dice.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/18/25.
//

import SwiftUI
internal import Combine

enum DiceOpType: String {
    case Add, Remove
}

struct Die: Identifiable, Comparable {
    var id: UUID = UUID()
    var value: Int = Int.random(in: 1...6)
    var hold: Bool = false
    var spin: Double = 0.0
    var blur: CGFloat = 0.0
    
    static func == (lhs: Die, rhs: Die) -> Bool {
        return lhs.value == rhs.value
    }
    
    static func < (lhs: Die, rhs: Die) -> Bool {
        return lhs.value < rhs.value
    }
}

@MainActor class DiceViewModel: ObservableObject {
    @Published var dice: [Die]
    
    init(count: Int) {
        self.dice = (0..<count).map { _ in Die() }
    }
    
    func changeDiceCount(op: DiceOpType) {
        if op == DiceOpType.Add {
            dice.append(Die())
        } else {
            dice.remove(at: dice.count - 1)
        }
    }
    
    func rollAll() {
        print("roll all!")
        
        for index in dice.indices {
                withAnimation(.easeIn) {
                dice[index].blur = 5.0
                dice[index].spin += round(Double.random(in: 1...6))
                dice[index].value = Int.random(in: 1...6)
            } completion: {
                withAnimation(.easeOut) {
                    for index in self.dice.indices {
                        self.dice[index].blur = 0.0
                        self.dice[index].spin += 1.0
                    }
                }
            }
        }
    }

    func rollDie(id: Die.ID) {
        print("roll die! \(id)")
        guard let index = dice.firstIndex(where: { $0.id == id }) else { return }

        withAnimation(.easeIn) {
            dice[index].blur = 5.0
            dice[index].spin += round(Double.random(in: 1...6))
            dice[index].value = Int.random(in: 1...6)
            print("Dice \(index): value: \(dice[index].value)")
        } completion: {
            withAnimation(.easeOut) {
                self.dice[index].blur = 0.0
                self.dice[index].spin += 1.0
            }
        }
    }
}
