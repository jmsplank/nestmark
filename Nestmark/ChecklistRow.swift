//
//  ChecklistRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct ChecklistRow: View {
    var checklist: Checklist

    private var items: [Item] {
        checklist.items ?? []
    }

    private var completedCount: Int {
        items.count(where: \.isCompleted)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(checklist.title)

            Text("\(completedCount)/\(items.count) completed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
