//
//  ChecklistSession.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import Foundation
import SwiftData

@Model
final class ChecklistSession {
    var timestamp: Date = Date.now
    var checklist: Checklist?

    @Relationship(deleteRule: .cascade, inverse: \SessionItem.session)
    var sessionItems: [SessionItem]? = []

    init(timestamp: Date = .now) {
        self.timestamp = timestamp
    }

    var sortedSessionItems: [SessionItem] {
        (sessionItems ?? []).sorted { $0.timestamp < $1.timestamp }
    }

    var completedCount: Int {
        (sessionItems ?? []).count(where: \.isCompleted)
    }
}
