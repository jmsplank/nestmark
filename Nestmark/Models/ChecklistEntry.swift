//
//  ChecklistEntry.swift
//  Nestmark
//
//  Created by James Plank on 11/05/2026.
//

import Foundation
import SwiftData

@Model
final class ChecklistEntry {
    var position: Int = 0
    var isComplete: Bool = false

    var checklist: Checklist?

    @Relationship
    var item: Item?

    @Relationship(deleteRule: .cascade)
    var childChecklist: Checklist?

    init(item: Item, position: Int) {
        self.item = item
        self.position = position
    }

    init(sublist: Checklist, position: Int) {
        self.childChecklist = sublist
        self.position = position
    }

    var kind: Kind { item != nil ? .item : .checklist }
    enum Kind { case item, checklist }
    
    func createSession(in session: SessionChecklist) -> SessionEntry {
        let entry = SessionEntry(position: position, session: session)
        entry.title = item?.title
        entry.childChecklist = childChecklist?.createSession()
        return entry
    }
}
