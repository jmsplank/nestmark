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
    @Query(sort: \Checklist.timestamp, order: .reverse) private var allChecklists: [Checklist]
    @State private var newTaskTitle = ""
    @State private var showingChecklistPicker = false

    private var availableChecklists: [Checklist] {
        allChecklists.filter { $0.id != checklist.id }
    }

    var body: some View {
        List {
            ForEach(checklist.sortedEntries) { entry in
                switch entry.kind {
                case .item:
                    if let item = entry.item {
                        ItemRow(item: item)
                    }
                case .checklist:
                    if let child = entry.childChecklist {
                        Label(child.title, systemImage: "list.bullet")
                    }
                }
            }
            .onDelete(perform: deleteEntries)
            .onMove(perform: moveEntries)

            Button("Add Checklist", systemImage: "plus") {
                showingChecklistPicker = true
            }
            .disabled(availableChecklists.isEmpty)
        }
        .navigationTitle(checklist.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .overlay {
            if checklist.entries.isEmpty {
                ContentUnavailableView("No Tasks", systemImage: "checklist")
            }
        }
        .sheet(isPresented: $showingChecklistPicker) {
            NavigationStack {
                List(availableChecklists) { sublist in
                    Button {
                        addChecklist(sublist)
                    } label: {
                        ChecklistRow(checklist: sublist)
                    }
                    .tint(.primary)
                }
                .navigationTitle("Choose Checklist")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingChecklistPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextField("New task", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addEntry)

                Button("Add", systemImage: "plus.circle.fill", action: addEntry)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(.bar)
        }
    }

    private func addChecklist(_ sublist: Checklist) {
        withAnimation {
            let entry = ChecklistEntry(sublist: sublist, position: checklist.entries.count)
            checklist.insert(entry, at: checklist.entries.count)
            showingChecklistPicker = false
        }
    }

    private func addEntry() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            let item = Item(title: trimmed)
            let entry = ChecklistEntry(item: item, position: checklist.entries.count)
            checklist.insert(entry, at: checklist.entries.count)
            newTaskTitle = ""
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            let sorted = checklist.sortedEntries
            for index in offsets {
                checklist.remove(sorted[index], from: modelContext)
            }
        }
    }

    private func moveEntries(from source: IndexSet, to destination: Int) {
        checklist.move(from: source, to: destination)
    }
}

#Preview {
    NavigationStack {
        ChecklistDetailView(checklist: Checklist(title: "Sample"))
    }
    .modelContainer(for: Checklist.self, inMemory: true)
}
