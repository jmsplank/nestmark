//
//  CompletionListView.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<SessionChecklist> { $0.parentEntry == nil },
        sort: \SessionChecklist.startedAt,
        order: .reverse
    ) private var sessions: [SessionChecklist]
    @Query(sort: \Checklist.timestamp, order: .reverse) private var checklists: [Checklist]
    @State private var path = NavigationPath()
    @State private var showingChecklistPicker = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        SessionChecklistRow(session: session, showChecklistTitle: true)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            withAnimation {
                                modelContext.delete(session)
                            }
                        }
                    }

                    ForEach(session.childSessions) { child in
                        NavigationLink(value: child) {
                            SessionChecklistRow(session: child, showChecklistTitle: true)
                        }
                        .padding(.leading)
                    }
                }
            }
            .navigationTitle("Complete")
            .navigationDestination(for: SessionChecklist.self) { session in
                ActiveSessionView(session: session)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Start New", systemImage: "plus") {
                        showingChecklistPicker = true
                    }
                    .disabled(checklists.isEmpty)
                }
            }
            .overlay {
                if sessions.isEmpty {
                    ContentUnavailableView {
                        Label("No Sessions", systemImage: "checkmark.circle")
                    } description: {
                        Text("Tap + to start completing a checklist")
                    }
                }
            }
            .sheet(isPresented: $showingChecklistPicker) {
                NavigationStack {
                    List(checklists) { checklist in
                        Button {
                            startNewSession(for: checklist)
                        } label: {
                            ChecklistRow(checklist: checklist)
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
        }
    }

    private func startNewSession(for checklist: Checklist) {
        let session = checklist.createSession(in: modelContext)
        showingChecklistPicker = false
        path.append(session)
    }
}

#Preview {
    SessionListView()
        .modelContainer(for: Checklist.self, inMemory: true)
}
