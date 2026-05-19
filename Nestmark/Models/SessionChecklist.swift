//
//  ChecklistSession.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import Foundation
import SwiftData

@Model
final class SessionChecklist {
    var title: String = ""
    var startedAt: Date = Date.now
    var completedAt: Date?

    var template: Checklist?
    var parentEntry: SessionEntry?

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.session)
    var entries: [SessionEntry]? = []

    init(title: String = "", startedAt: Date = .now, template: Checklist? = nil) {
        self.title = title
        self.startedAt = startedAt
        self.template = template
    }
}
