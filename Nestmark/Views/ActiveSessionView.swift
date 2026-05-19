//
//  ActiveSessionView.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct ActiveSessionView: View {
    var session: SessionChecklist

    var body: some View {
        List {
            ForEach(session.sortedEntries) { entry in
                switch entry.kind {
                case .item:
                    SessionEntryRow(sessionEntry: entry)
                case .checklist:
                    if let child = entry.childChecklist {
                        NavigationLink(value: child) {
                            Label(child.title, systemImage: "list.bullet")
                        }
                    }
                }
            }
        }
        .navigationTitle(session.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(session.completedCount)/\(session.totalEntries)")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
