//
//  ContentView.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var newTaskTitle = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    TaskRow(item: item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Nestmark")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No Tasks", systemImage: "checklist")
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("New task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addItem)

                    Button("Add", systemImage: "plus.circle.fill", action: addItem)
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(.bar)
            }
        }
    }

    private func addItem() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            let newItem = Item(title: trimmed)
            modelContext.insert(newItem)
            newTaskTitle = ""
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
