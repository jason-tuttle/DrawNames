//
//  DrawNamesView.swift
//  DrawNames
//
//  Created by Jason Tuttle on 12/15/25.
//
import SwiftUI

struct DrawNamesView: View {
    @State private var names: [String] = []
    @State private var newName: String = ""
    @State private var matches: [MatchPair] = [];
    @State private var rtfUrl: URL?
    @FocusState private var isFocused: Bool
    
    
    func drawNames() -> [MatchPair] {
        let count = names.count
        guard count > 2 else {
            return names.map { MatchPair(giver: $0, receiver: $0) }
        }
        var indices = Array(0..<count)
        
        repeat {
            indices.shuffle()
        } while zip(indices, 0..<count).contains(where: { $0 == $1 })
        
        let pairs = (0..<count).map { index in
            MatchPair(giver: names[index], receiver: names[indices[index]])
        }
        
        return pairs
    }
    
    func addName() {
        names.append(newName.trimmingCharacters(in: .whitespacesAndNewlines))
        matches = drawNames()
        newName = ""
    }
    
    func makeRTF(from pairs: [MatchPair]) -> Data? {
        let title = "Draw Names Result\n\n"
        let body = pairs.map { "\($0.giver) ➔ \($0.receiver)" }.joined(separator: "\n")
        
        let fullText = title + body
        let attributed = NSMutableAttributedString(string: fullText)
        
        attributed.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 22)
        ], range: NSRange(location: 0, length: title.count))
        
        return try? attributed.data(
            from: NSRange(location: 0, length: attributed.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        )
    }
    
    func exportRTF(pairs: [MatchPair]) -> URL? {
        guard let data = makeRTF(from: pairs) else { return nil }
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Draw Names Result.rtf")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Failed to write RTF: \(error)")
            return nil
        }
    }
    var body: some View {
        ZStack {
            LinearGradient(colors: [.yellow, .orange, .pink], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Text("Randomly assigns pairs of names as you add them!").font(Font.subheadline).foregroundStyle(.secondary)
                ScrollView {
                    Grid(verticalSpacing: 8) {
                        GridRow {
                            Spacer()
                            Image(systemName: "person.fill")
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                            Image(systemName: "arrow.right")
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                            Image(systemName: "person")
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                            Spacer()
                        }
                        ForEach((0..<names.count), id: \.self) { index in
                            GridRow {
                                Spacer()
                                Text(matches[index].giver)
                                Image(systemName: "arrow.right")
                                if index < matches.count {
                                    Text(matches[index].receiver)
                                        .transition(.blurReplace)
                                } else {
                                    EmptyView()
                                }
                                Spacer()
                            }
                            .animation(.snappy, value: names.count)
                        }
                        
                    }
                    .padding(.bottom)
                    .onAppear {
                        isFocused = true
                    }
                    if names.count > 2 {
                        Button("Reshuffle", systemImage: "person.2.arrow.trianglehead.counterclockwise") {
                            matches = drawNames()
                        }
                        .disabled(names.count < 2)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .font(Font.subheadline)
                        .foregroundStyle(.primary)
                        .buttonStyle(.bordered)
                        
                    }
                } // ScrollView
                
                TextField("Enter a name", text: $newName)
                    .onSubmit {
                        addName()
                    }
                    .focused($isFocused)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                HStack(spacing: 12) {
                    Button("Add another", systemImage: "plus.circle") {
                        addName()
                        isFocused = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newName.isEmpty)
                    
                    if isFocused {
                        Button("Done") {
                            isFocused = false
                        }
                    }
                }
            } // VStack
        }
    }
}

#Preview {
    DrawNamesView()
}
