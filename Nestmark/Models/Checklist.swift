//
//  Checklist.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import Foundation
import SwiftData

@Model
final class Checklist {
    var title: String = ""
    var timestamp: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \ChecklistEntry.checklist)
    var entries: [ChecklistEntry] = []

    init(title: String = "", timestamp: Date = .now) {
        self.title = title
        self.timestamp = timestamp
    }

    func createSession(in context: ModelContext) -> SessionChecklist {
        let session = SessionChecklist(title: title, template: self)
        let sorted = entries.sorted { $0.position < $1.position }
        session.entries = sorted.map { $0.createSession(in: session, context: context) }
        context.insert(session)
        return session
    }
}
