//
//  RelationshipCascadeTests.swift
//  NestmarkTests
//
//  Created by James Plank on 20/05/2026.
//

import Testing
import Foundation
import SwiftData
@testable import Nestmark

@MainActor
@Suite("Relationship cascades")
struct RelationshipCascadeTests {
    @Test func settingEntryChecklistPopulatesInverse() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        let entry = addItemEntry(to: checklist, in: context, position: 0, title: "Task")

        #expect(checklist.entries.contains { $0.persistentModelID == entry.persistentModelID })
    }

    @Test func deletingChecklistCascadesToEntries() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        for index in 0..<3 {
            addItemEntry(to: checklist, in: context, position: index, title: "Entry \(index)")
        }

        try context.save()
        let preCount = try context.fetch(FetchDescriptor<ChecklistEntry>()).count
        try #require(preCount == 3)

        context.delete(checklist)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<ChecklistEntry>())
        #expect(remaining.isEmpty)
    }

    @Test func deletingEntryWithSublistCascadesToChildChecklist() throws {
        let context = try makeTestContext()
        let root = Checklist(title: "Root")
        context.insert(root)

        let sub = Checklist(title: "Sub")
        context.insert(sub)
        let entry = addSublistEntry(to: root, in: context, position: 0, sublist: sub)

        try context.save()
        let preCount = try context.fetch(FetchDescriptor<Checklist>()).count
        try #require(preCount == 2)

        context.delete(entry)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<Checklist>())
        #expect(remaining.count == 1)
        #expect(remaining.first?.title == "Root")
    }

    @Test func deletingSessionCascadesToSessionEntries() throws {
        let context = try makeTestContext()
        let session = SessionChecklist(title: "Session")
        context.insert(session)

        for position in 0..<3 {
            addSessionEntry(to: session, in: context, position: position, title: "Entry \(position)")
        }

        try context.save()
        let preCount = try context.fetch(FetchDescriptor<SessionEntry>()).count
        try #require(preCount == 3)

        context.delete(session)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<SessionEntry>())
        #expect(remaining.isEmpty)
    }

    @Test func deletingSessionEntryCascadesToNestedSession() throws {
        let context = try makeTestContext()
        let root = SessionChecklist(title: "Root")
        context.insert(root)

        let nested = SessionChecklist(title: "Nested")
        context.insert(nested)
        let entry = addSessionEntry(to: root, in: context, position: 0, child: nested)

        try context.save()
        let preCount = try context.fetch(FetchDescriptor<SessionChecklist>()).count
        try #require(preCount == 2)

        context.delete(entry)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<SessionChecklist>())
        #expect(remaining.count == 1)
        #expect(remaining.first?.title == "Root")
    }
}
