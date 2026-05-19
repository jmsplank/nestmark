//
//  ChecklistRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct ChecklistRow: View {
    var checklist: Checklist

    private var itemCount: Int {
        checklist.entries.count
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(checklist.title)

            Text("^[\(itemCount) item](inflect: true)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
