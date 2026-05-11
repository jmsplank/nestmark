//
//  SessionRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct SessionChecklistRow: View {
    var session: SessionChecklist
    var showChecklistTitle = false

    var body: some View {
        VStack(alignment: .leading) {
            if showChecklistTitle, let title = session.template?.title {
                Text(title)
            }

            Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                .font(showChecklistTitle ? .caption : .body)
                .foregroundStyle(showChecklistTitle ? .secondary : .primary)

            Text("\(session.completedCount)/\(session.totalEntries) completed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
