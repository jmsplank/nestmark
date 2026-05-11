//
//  SessionItemRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct SessionItemRow: View {
    @Bindable var sessionItem: SessionItem

    var body: some View {
        Button(action: toggleCompleted) {
            HStack {
                Image(systemName: sessionItem.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(sessionItem.isCompleted ? .green : .secondary)
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(sessionItem.title)
                        .strikethrough(sessionItem.isCompleted)
                        .foregroundStyle(sessionItem.isCompleted ? .secondary : .primary)

                    if sessionItem.isCompleted, let completedAt = sessionItem.completedAt {
                        Text(completedAt.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .tint(.primary)
        .accessibilityValue(sessionItem.isCompleted ? "Completed" : "Not completed")
    }

    private func toggleCompleted() {
        withAnimation {
            sessionItem.isCompleted.toggle()
            sessionItem.completedAt = sessionItem.isCompleted ? .now : nil
        }
    }
}
