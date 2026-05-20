//
//  SessionChecklistHelpersTests.swift
//  NestmarkTests
//
//  Created by James Plank on 20/05/2026.
//

import Testing
import Foundation
import SwiftData
@testable import Nestmark

@MainActor
@Suite("SessionChecklist helpers")
struct SessionChecklistHelpersTests {
    @Test func sortedEntriesReturnsAscendingByPosition() throws {
        let context = try makeTestContext()
        let session = SessionChecklist(title: "Session")
        context.insert(session)

        for position in [2, 0, 1] {
            addSessionEntry(to: session, in: context, position: position, title: "Entry \(position)")
        }

        let sorted = session.sortedEntries
        #expect(sorted.map(\.position) == [0, 1, 2])
        #expect(sorted.map(\.title) == ["Entry 0", "Entry 1", "Entry 2"])
    }

    @Test func totalEntriesReflectsCount() throws {
        let context = try makeTestContext()
        let session = SessionChecklist(title: "Session")
        context.insert(session)

        for position in 0..<5 {
            addSessionEntry(to: session, in: context, position: position)
        }

        #expect(session.totalEntries == 5)
    }

    @Test func totalEntriesIsZeroForEmptySession() {
        let session = SessionChecklist(title: "Empty")
        #expect(session.totalEntries == 0)
    }

    @Test(arguments: [
        ([false, false, false], 0),
        ([true, false, false], 1),
        ([true, true, false], 2),
        ([true, true, true], 3),
        ([false, true, false, true], 2)
    ])
    func completedCountMatchesFlags(flags: [Bool], expected: Int) throws {
        let context = try makeTestContext()
        let session = SessionChecklist(title: "Session")
        context.insert(session)

        for (position, isComplete) in flags.enumerated() {
            addSessionEntry(to: session, in: context, position: position, isComplete: isComplete)
        }

        #expect(session.completedCount == expected)
    }

    @Test func childSessionsReturnsOnlyNonNilInSortedOrder() throws {
        let context = try makeTestContext()
        let session = SessionChecklist(title: "Session")
        context.insert(session)

        // Three entries; only the first and last have child sessions.
        let childA = SessionChecklist(title: "ChildA")
        context.insert(childA)
        addSessionEntry(to: session, in: context, position: 0, child: childA)

        addSessionEntry(to: session, in: context, position: 1, title: "Plain item")

        let childC = SessionChecklist(title: "ChildC")
        context.insert(childC)
        addSessionEntry(to: session, in: context, position: 2, child: childC)

        let children = session.childSessions
        #expect(children.map(\.title) == ["ChildA", "ChildC"])
    }

    @Test func childSessionsIsEmptyWhenNoEntriesHaveChildren() throws {
        let context = try makeTestContext()
        let session = SessionChecklist(title: "Session")
        context.insert(session)

        for position in 0..<3 {
            addSessionEntry(to: session, in: context, position: position, title: "Item \(position)")
        }

        #expect(session.childSessions.isEmpty)
    }

    @Test func helpersHandleNilEntriesArrayGracefully() {
        let session = SessionChecklist(title: "Session")
        session.entries = nil

        #expect(session.sortedEntries.isEmpty)
        #expect(session.totalEntries == 0)
        #expect(session.completedCount == 0)
        #expect(session.childSessions.isEmpty)
    }
}
