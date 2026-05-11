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

    @Relationship(deleteRule: .cascade, inverse: \Item.checklist)
    var items: [Item]? = []

    @Relationship(deleteRule: .cascade, inverse: \ChecklistSession.checklist)
    var sessions: [ChecklistSession]? = []

    init(title: String = "", timestamp: Date = .now) {
        self.title = title
        self.timestamp = timestamp
    }

    var sortedItems: [Item] {
        (items ?? []).sorted { $0.timestamp < $1.timestamp }
    }

    @discardableResult
    func createSession(in context: ModelContext) -> ChecklistSession {
        let session = ChecklistSession()
        session.checklist = self
        context.insert(session)

        for item in sortedItems {
            let sessionItem = SessionItem(title: item.title)
            sessionItem.session = session
            context.insert(sessionItem)
        }

        return session
    }
}
