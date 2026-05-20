//
//  NestmarkTests.swift
//  NestmarkTests
//
//  Created by James Plank on 09/05/2026.
//

import Testing
import Foundation
import SwiftData
@testable import Nestmark

@MainActor
@Suite("Model defaults")
struct ModelDefaultsTests {
    @Test func itemDefaults() {
        let item = Item()
        #expect(item.title == "")
        #expect(item.isCompleted == false)
        #expect(item.completedAt == nil)
    }

    @Test func itemInitWithTitle() {
        let item = Item(title: "Buy milk")
        #expect(item.title == "Buy milk")
    }

    @Test func checklistDefaults() {
        let checklist = Checklist()
        #expect(checklist.title == "")
        #expect(checklist.entries.isEmpty)
    }

    @Test func sessionChecklistDefaults() {
        let session = SessionChecklist()
        #expect(session.title == "")
        #expect(session.completedAt == nil)
        #expect(session.template == nil)
        #expect(session.parentEntry == nil)
        #expect((session.entries ?? []).isEmpty)
    }

    @Test func sessionEntryDefaults() {
        let entry = SessionEntry(position: 5)
        #expect(entry.position == 5)
        #expect(entry.isComplete == false)
        #expect(entry.completedAt == nil)
        #expect(entry.title == "")
        #expect(entry.childChecklist == nil)
    }
}

@MainActor
@Suite("ChecklistEntry kind")
struct ChecklistEntryKindTests {
    @Test func itemInitProducesItemKind() {
        let entry = ChecklistEntry(item: Item(title: "Task"), position: 3)
        #expect(entry.kind == .item)
        #expect(entry.item != nil)
        #expect(entry.childChecklist == nil)
        #expect(entry.position == 3)
    }

    @Test func sublistInitProducesChecklistKind() {
        let entry = ChecklistEntry(sublist: Checklist(title: "Sub"), position: 2)
        #expect(entry.kind == .checklist)
        #expect(entry.item == nil)
        #expect(entry.childChecklist != nil)
        #expect(entry.position == 2)
    }

    @Test func sessionEntryKindFollowsChildChecklist() {
        let itemEntry = SessionEntry(position: 0)
        itemEntry.title = "Task"
        #expect(itemEntry.kind == .item)

        let checklistEntry = SessionEntry(position: 0)
        checklistEntry.childChecklist = SessionChecklist(title: "Sub")
        #expect(checklistEntry.kind == .checklist)
    }
}
