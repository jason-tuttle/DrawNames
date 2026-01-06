
//
//  ContentView.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/8/25.
//

import SwiftUI

struct MatchPair: Identifiable {
    let id = UUID()
    let giver: String
    let receiver: String
}

struct ContentView: View {
    var body: some View {
        TabView {
            DrawNamesView()
                .tabItem {
                    Label("Pair Up", systemImage: "person.line.dotted.person.fill")
                }
            
            RollDiceView()
                .tabItem {
                    Label("Roll Dice", systemImage: "dice")
                }
            
            SpinnerView()
                .tabItem {
                    Label("Spin!", systemImage: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
                }
            
            HourglassView()
                .tabItem {
                    Label("Timer", systemImage: "hourglass")
                }
        }
    }
}

// Draw straws?

// Coin Flip

// Timer / hourglass

#Preview {
    ContentView()
}
