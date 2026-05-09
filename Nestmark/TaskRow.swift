//
//  TaskRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct TaskRow: View {
    @Bindable var item: Item

    var body: some View {
        Button(action: toggleCompleted) {
            HStack {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                    .imageScale(.large)

                Text(item.title)
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
            }
        }
        .tint(.primary)
        .accessibilityValue(item.isCompleted ? "Completed" : "Not completed")
    }

    private func toggleCompleted() {
        withAnimation {
            item.isCompleted.toggle()
        }
    }
}
