//
//  ContentView.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Complete", systemImage: "checkmark.circle") {
                SessionListView()
            }

            Tab("Checklists", systemImage: "square.and.pencil") {
                ChecklistListView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Checklist.self, inMemory: true)
}
