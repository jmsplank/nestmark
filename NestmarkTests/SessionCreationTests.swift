//
//  SessionCreationTests.swift
//  NestmarkTests
//
//  Created by James Plank on 20/05/2026.
//

import Testing
import Foundation
import SwiftData
@testable import Nestmark

@MainActor
@Suite("Checklist.createSession")
struct SessionCreationTests {
    @Test func snapshotsTitleAtCreationTime() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "Original")
        context.insert(checklist)

        let session = checklist.createSession(in: context)
        checklist.title = "Renamed"

        #expect(session.title == "Original")
    }

    @Test func templateBackReferenceIsSet() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        let session = checklist.createSession(in: context)
        #expect(session.template === checklist)
    }

    @Test func sessionIsInsertedIntoContext() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        let session = checklist.createSession(in: context)

        let fetched = try context.fetch(FetchDescriptor<SessionChecklist>())
        #expect(fetched.contains { $0.persistentModelID == session.persistentModelID })
    }

    @Test func emptyChecklistProducesEmptySession() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "Empty")
        context.insert(checklist)

        let session = checklist.createSession(in: context)
        #expect(session.title == "Empty")
        #expect(session.sortedEntries.isEmpty)
    }

    @Test func preservesEntryOrderingBySortedPosition() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        // Insert entries with positions in non-ascending order.
        for (position, title) in zip([2, 0, 1], ["C", "A", "B"]) {
            addItemEntry(to: checklist, in: context, position: position, title: title)
        }

        let session = checklist.createSession(in: context)
        #expect(session.sortedEntries.map(\.title) == ["A", "B", "C"])
        #expect(session.sortedEntries.map(\.position) == [0, 1, 2])
    }

    @Test func itemEntrySnapshotsItemTitle() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        let entry = addItemEntry(to: checklist, in: context, position: 0, title: "Buy milk")

        let session = checklist.createSession(in: context)
        entry.item?.title = "Buy bread"

        let snapshotted = try #require(session.sortedEntries.first)
        #expect(snapshotted.title == "Buy milk")
    }

    @Test func sublistEntryProducesNestedSessionWithBackReference() throws {
        let context = try makeTestContext()

        let sublist = Checklist(title: "Sub")
        context.insert(sublist)
        addItemEntry(to: sublist, in: context, position: 0, title: "Nested item")

        let root = Checklist(title: "Root")
        context.insert(root)
        addSublistEntry(to: root, in: context, position: 0, sublist: sublist)

        let session = root.createSession(in: context)
        let parentEntry = try #require(session.sortedEntries.first)
        let nested = try #require(parentEntry.childChecklist)

        #expect(nested.title == "Sub")
        #expect(nested.sortedEntries.count == 1)
        #expect(nested.sortedEntries.first?.title == "Nested item")
        #expect(nested.parentEntry === parentEntry, "Nested session should link back to its parent SessionEntry")
    }

    @Test func recursesThroughDeepNesting() throws {
        let context = try makeTestContext()

        let sub2 = Checklist(title: "Sub2")
        context.insert(sub2)
        addItemEntry(to: sub2, in: context, position: 0, title: "Leaf")

        let sub1 = Checklist(title: "Sub1")
        context.insert(sub1)
        addSublistEntry(to: sub1, in: context, position: 0, sublist: sub2)

        let root = Checklist(title: "Root")
        context.insert(root)
        addSublistEntry(to: root, in: context, position: 0, sublist: sub1)

        let session = root.createSession(in: context)
        let level1 = try #require(session.sortedEntries.first?.childChecklist)
        let level2 = try #require(level1.sortedEntries.first?.childChecklist)

        #expect(level1.title == "Sub1")
        #expect(level2.title == "Sub2")
        #expect(level2.sortedEntries.first?.title == "Leaf")
    }

    @Test func degenerateEntryProducesEmptyTitleItemKind() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        // Construct an entry that has neither an item nor a child checklist.
        let entry = addItemEntry(to: checklist, in: context, position: 0, title: "Placeholder")
        entry.item = nil

        let session = checklist.createSession(in: context)
        let sessionEntry = try #require(session.sortedEntries.first)
        #expect(sessionEntry.title == "")
        #expect(sessionEntry.kind == .item)
    }
}
