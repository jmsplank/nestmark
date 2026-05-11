//
//  ChecklistDetailView.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI
import SwiftData

struct ChecklistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var checklist: Checklist
    @State private var newTaskTitle = ""

    var body: some View {
        List {
            ForEach(checklist.sortedItems) { item in
                ItemRow(item: item)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle(checklist.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .overlay {
            if (checklist.items ?? []).isEmpty {
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

    private func addItem() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            let newItem = Item(title: trimmed)
            newItem.checklist = checklist
            modelContext.insert(newItem)
            newTaskTitle = ""
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let items = checklist.sortedItems
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChecklistDetailView(checklist: Checklist(title: "Sample"))
    }
    .modelContainer(for: Checklist.self, inMemory: true)
}
