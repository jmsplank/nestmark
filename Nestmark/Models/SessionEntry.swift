//
//  SessionEntry.swift
//  Nestmark
//
//  Created by James Plank on 11/05/2026.
//

import Foundation
import SwiftData

@Model
final class SessionEntry {
    var position: Int = 0
    var isComplete: Bool = false
    var completedAt: Date?

    var session: SessionChecklist?

    // Snapshotted item data — frozen at instantiation time
    var title: String = ""

    // Nested run for sublist entries
    @Relationship(deleteRule: .cascade, inverse: \SessionChecklist.parentEntry)
    var childChecklist: SessionChecklist?

    init(position: Int, session: SessionChecklist? = nil) {
        self.position = position
        self.session = session
    }

    var kind: ChecklistEntry.Kind {
        childChecklist != nil ? .checklist : .item
    }
}
