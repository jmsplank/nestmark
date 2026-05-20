//
//  ChecklistOperationsTests.swift
//  NestmarkTests
//
//  Created by James Plank on 20/05/2026.
//

import Testing
import Foundation
import SwiftData
@testable import Nestmark

@MainActor
@Suite("Checklist operations")
struct ChecklistOperationsTests {
    @Test func sortedEntriesReturnsAscendingByPosition() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        // Insert entries with positions in non-ascending order.
        for (position, title) in zip([2, 0, 1], ["C", "A", "B"]) {
            addItemEntry(to: checklist, in: context, position: position, title: title)
        }

        let sorted = checklist.sortedEntries
        #expect(sorted.map(\.position) == [0, 1, 2])
        #expect(sorted.map { $0.item?.title } == ["A", "B", "C"])
    }

    @Test func insertAtStartShiftsAllSiblings() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        for index in 0..<3 {
            addItemEntry(to: checklist, in: context, position: index, title: "Old \(index)")
        }

        let newItem = Item(title: "New")
        let newEntry = ChecklistEntry(item: newItem, position: -1)
        context.insert(newItem)
        context.insert(newEntry)
        checklist.insert(newEntry, at: 0)

        let sorted = checklist.sortedEntries
        #expect(sorted.count == 4)
        #expect(sorted.map(\.position) == [0, 1, 2, 3])
        #expect(sorted.first?.item?.title == "New")
        #expect(newEntry.checklist === checklist)
    }

    @Test func insertInMiddleShiftsOnlyFollowingSiblings() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        for index in 0..<3 {
            addItemEntry(to: checklist, in: context, position: index, title: "Old \(index)")
        }

        let newItem = Item(title: "New")
        let newEntry = ChecklistEntry(item: newItem, position: -1)
        context.insert(newItem)
        context.insert(newEntry)
        checklist.insert(newEntry, at: 1)

        let sorted = checklist.sortedEntries
        #expect(sorted.count == 4)
        #expect(sorted.map(\.position) == [0, 1, 2, 3])
        #expect(sorted.map { $0.item?.title } == ["Old 0", "New", "Old 1", "Old 2"])
    }

    @Test func insertAtEndDoesNotShiftSiblings() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        for index in 0..<3 {
            addItemEntry(to: checklist, in: context, position: index, title: "Old \(index)")
        }

        let newItem = Item(title: "New")
        let newEntry = ChecklistEntry(item: newItem, position: -1)
        context.insert(newItem)
        context.insert(newEntry)
        checklist.insert(newEntry, at: 3)

        let sorted = checklist.sortedEntries
        #expect(sorted.count == 4)
        #expect(sorted.map(\.position) == [0, 1, 2, 3])
        #expect(sorted.last?.item?.title == "New")
    }

    @Test func removeFromMiddleClosesGap() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        var entries: [ChecklistEntry] = []
        for index in 0..<4 {
            entries.append(
                addItemEntry(to: checklist, in: context, position: index, title: "Entry \(index)")
            )
        }

        checklist.remove(entries[1], from: context)
        try context.save()

        let sorted = checklist.sortedEntries
        #expect(sorted.count == 3)
        #expect(sorted.map(\.position) == [0, 1, 2])
        #expect(sorted.map { $0.item?.title } == ["Entry 0", "Entry 2", "Entry 3"])
    }

    @Test func removeFromStartReindexesRemaining() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        var entries: [ChecklistEntry] = []
        for index in 0..<3 {
            entries.append(
                addItemEntry(to: checklist, in: context, position: index, title: "Entry \(index)")
            )
        }

        checklist.remove(entries[0], from: context)
        try context.save()

        let sorted = checklist.sortedEntries
        #expect(sorted.count == 2)
        #expect(sorted.map(\.position) == [0, 1])
        #expect(sorted.map { $0.item?.title } == ["Entry 1", "Entry 2"])
    }

    @Test func removeFromEndLeavesOthersUnchanged() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        var entries: [ChecklistEntry] = []
        for index in 0..<3 {
            entries.append(
                addItemEntry(to: checklist, in: context, position: index, title: "Entry \(index)")
            )
        }

        checklist.remove(entries[2], from: context)
        try context.save()

        let sorted = checklist.sortedEntries
        #expect(sorted.count == 2)
        #expect(sorted.map(\.position) == [0, 1])
        #expect(sorted.map { $0.item?.title } == ["Entry 0", "Entry 1"])
    }

    @Test func moveForwardReindexesContiguously() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        for index in 0..<4 {
            addItemEntry(to: checklist, in: context, position: index, title: "Entry \(index)")
        }

        // Move first entry to offset 3 — Foundation move semantics put it between offsets 2 and 3.
        checklist.move(from: IndexSet(integer: 0), to: 3)

        let sorted = checklist.sortedEntries
        #expect(sorted.map(\.position) == [0, 1, 2, 3])
        #expect(sorted.map { $0.item?.title } == ["Entry 1", "Entry 2", "Entry 0", "Entry 3"])
    }

    @Test func moveBackwardReindexesContiguously() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        for index in 0..<4 {
            addItemEntry(to: checklist, in: context, position: index, title: "Entry \(index)")
        }

        checklist.move(from: IndexSet(integer: 3), to: 0)

        let sorted = checklist.sortedEntries
        #expect(sorted.map(\.position) == [0, 1, 2, 3])
        #expect(sorted.map { $0.item?.title } == ["Entry 3", "Entry 0", "Entry 1", "Entry 2"])
    }

    @Test func moveToSameOffsetLeavesOrderUnchanged() throws {
        let context = try makeTestContext()
        let checklist = Checklist(title: "List")
        context.insert(checklist)

        for index in 0..<3 {
            addItemEntry(to: checklist, in: context, position: index, title: "Entry \(index)")
        }

        checklist.move(from: IndexSet(integer: 1), to: 1)

        let sorted = checklist.sortedEntries
        #expect(sorted.map(\.position) == [0, 1, 2])
        #expect(sorted.map { $0.item?.title } == ["Entry 0", "Entry 1", "Entry 2"])
    }
}
