//
//  SessionItemRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct SessionEntryRow: View {
    @Bindable var sessionEntry: SessionEntry

    var body: some View {
        Button(action: toggleCompleted) {
            HStack {
                Image(systemName: sessionEntry.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(sessionEntry.isComplete ? .green : .secondary)
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(sessionEntry.title)
                        .strikethrough(sessionEntry.isComplete)
                        .foregroundStyle(sessionEntry.isComplete ? .secondary : .primary)

                    if sessionEntry.isComplete, let completedAt = sessionEntry.completedAt {
                        Text(completedAt.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .tint(.primary)
        .accessibilityValue(sessionEntry.isComplete ? "Complete" : "Not complete")
    }

    private func toggleCompleted() {
        withAnimation {
            sessionEntry.isComplete.toggle()
            sessionEntry.completedAt = sessionEntry.isComplete ? .now : nil
        }
    }
}
