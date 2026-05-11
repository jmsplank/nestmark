//
//  SessionRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct SessionRow: View {
    var session: ChecklistSession
    var showChecklistTitle = false

    var body: some View {
        VStack(alignment: .leading) {
            if showChecklistTitle, let title = session.checklist?.title {
                Text(title)
            }

            Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(showChecklistTitle ? .caption : .body)
                .foregroundStyle(showChecklistTitle ? .secondary : .primary)

            Text("\(session.completedCount)/\((session.sessionItems ?? []).count) completed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
