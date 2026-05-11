//
//  ActiveSessionView.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct ActiveSessionView: View {
    var session: ChecklistSession

    var body: some View {
        List {
            ForEach(session.sortedSessionItems) { item in
                SessionItemRow(sessionItem: item)
            }
        }
        .navigationTitle(session.checklist?.title ?? "Session")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(session.completedCount)/\((session.sessionItems ?? []).count)")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
