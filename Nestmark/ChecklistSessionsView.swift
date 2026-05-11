//
//  ChecklistSessionsView.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI
import SwiftData

struct ChecklistSessionsView: View {
    @Environment(\.modelContext) private var modelContext
    var checklist: Checklist
    @Binding var path: NavigationPath

    private var sortedSessions: [ChecklistSession] {
        (checklist.sessions ?? []).sorted { $0.timestamp > $1.timestamp }
    }

    private var hasSessions: Bool {
        (checklist.sessions ?? []).isEmpty == false
    }

    var body: some View {
        List {
            Section {
                Button("Start New", systemImage: "plus.circle.fill", action: startNewSession)
            }

            if hasSessions {
                Section("Past Sessions") {
                    ForEach(sortedSessions) { session in
                        NavigationLink(value: session) {
                            SessionRow(session: session)
                        }
                    }
                    .onDelete(perform: deleteSessions)
                }
            }
        }
        .navigationTitle(checklist.title)
    }

    private func startNewSession() {
        let session = checklist.createSession(in: modelContext)
        path.append(session)
    }

    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            let sessions = sortedSessions
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
    }
}
