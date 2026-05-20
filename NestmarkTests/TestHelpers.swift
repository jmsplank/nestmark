//
//  TestHelpers.swift
//  NestmarkTests
//
//  Created by James Plank on 20/05/2026.
//

import Foundation
import SwiftData
import Testing
@testable import Nestmark

@MainActor
func makeTestContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: Checklist.self, Item.self, ChecklistEntry.self,
            SessionChecklist.self, SessionEntry.self,
        configurations: config
    )
    return ModelContext(container)
}

@MainActor
@discardableResult
func addItemEntry(
    to checklist: Checklist,
    in context: ModelContext,
    position: Int,
    title: String
) -> ChecklistEntry {
    let item = Item(title: title)
    let entry = ChecklistEntry(item: item, position: position)
    context.insert(item)
    context.insert(entry)
    entry.checklist = checklist
    return entry
}

@MainActor
@discardableResult
func addSublistEntry(
    to checklist: Checklist,
    in context: ModelContext,
    position: Int,
    sublist: Checklist
) -> ChecklistEntry {
    let entry = ChecklistEntry(sublist: sublist, position: position)
    context.insert(entry)
    entry.checklist = checklist
    return entry
}

@MainActor
@discardableResult
func addSessionEntry(
    to session: SessionChecklist,
    in context: ModelContext,
    position: Int,
    title: String = "",
    isComplete: Bool = false,
    child: SessionChecklist? = nil
) -> SessionEntry {
    let entry = SessionEntry(position: position, session: session)
    entry.title = title
    entry.isComplete = isComplete
    entry.childChecklist = child
    context.insert(entry)
    return entry
}
