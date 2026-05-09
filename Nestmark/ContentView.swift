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
    @Query(sort: \Checklist.timestamp, order: .reverse) private var checklists: [Checklist]
    @State private var newChecklistTitle = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(checklists) { checklist in
                    NavigationLink(value: checklist) {
                        ChecklistRow(checklist: checklist)
                    }
                }
                .onDelete(perform: deleteChecklists)
            }
            .navigationTitle("Nestmark")
            .navigationDestination(for: Checklist.self) { checklist in
                ChecklistDetailView(checklist: checklist)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .overlay {
                if checklists.isEmpty {
                    ContentUnavailableView("No Checklists", systemImage: "list.bullet.clipboard")
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("New checklist", text: $newChecklistTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addChecklist)

                    Button("Add", systemImage: "plus.circle.fill", action: addChecklist)
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .disabled(newChecklistTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(.bar)
            }
        }
    }

    private func addChecklist() {
        let trimmed = newChecklistTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            let checklist = Checklist(title: trimmed)
            modelContext.insert(checklist)
            newChecklistTitle = ""
        }
    }

    private func deleteChecklists(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(checklists[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Checklist.self, inMemory: true)
}
