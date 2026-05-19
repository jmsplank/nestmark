//
//  SessionChecklist+Helpers.swift
//  Nestmark
//
//  Created by James Plank on 11/05/2026.
//

import Foundation

extension SessionChecklist {
    var sortedEntries: [SessionEntry] {
        (entries ?? []).sorted { $0.position < $1.position }
    }

    var childSessions: [SessionChecklist] {
        sortedEntries.compactMap(\.childChecklist)
    }

    var totalEntries: Int {
        (entries ?? []).count
    }

    var completedCount: Int {
        (entries ?? []).count(where: \.isComplete)
    }
}
