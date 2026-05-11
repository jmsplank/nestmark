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

@Suite("Model Tests")
struct ModelTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Checklist.self, Item.self, ChecklistSession.self, SessionItem.self,
            configurations: config
        )
        context = ModelContext(container)
    }

    @Test func itemDefaultValues() {
        let item = Item()
        context.insert(item)
        #expect(item.title == "")
        #expect(item.isCompleted == false)
        #expect(item.checklist == nil)
    }

    @Test func itemInitWithTitle() {
        let item = Item(title: "Buy milk")
        context.insert(item)
        #expect(item.title == "Buy milk")
        #expect(item.isCompleted == false)
    }

    @Test func checklistDefaultValues() {
        let checklist = Checklist()
        context.insert(checklist)
        #expect(checklist.title == "")
        #expect(checklist.items?.isEmpty == true)
    }

    @Test func checklistInitWithTitle() {
        let checklist = Checklist(title: "Shopping")
        context.insert(checklist)
        #expect(checklist.title == "Shopping")
    }

    @Test func addItemToChecklist() throws {
        let checklist = Checklist(title: "Errands")
        context.insert(checklist)

        let item = Item(title: "Pick up package")
        item.checklist = checklist
        context.insert(item)

        try context.save()

        let items = try #require(checklist.items)
        #expect(items.count == 1)
        let first = try #require(items.first)
        #expect(first.title == "Pick up package")
        #expect(item.checklist === checklist)
    }

    @Test func cascadeDeleteRemovesItems() throws {
        let checklist = Checklist(title: "To delete")
        context.insert(checklist)

        let item1 = Item(title: "Task 1")
        item1.checklist = checklist
        context.insert(item1)

        let item2 = Item(title: "Task 2")
        item2.checklist = checklist
        context.insert(item2)

        try context.save()
        try #require(checklist.items?.count == 2)

        let itemID1 = item1.persistentModelID
        let itemID2 = item2.persistentModelID

        context.delete(checklist)
        try context.save()

        let descriptor = FetchDescriptor<Item>()
        let remaining = try context.fetch(descriptor)
        let orphaned = remaining.filter { $0.persistentModelID == itemID1 || $0.persistentModelID == itemID2 }
        #expect(orphaned.isEmpty)
    }

    @Test func toggleItemCompletion() {
        let item = Item(title: "Test task")
        context.insert(item)
        #expect(item.isCompleted == false)
        item.isCompleted.toggle()
        #expect(item.isCompleted == true)
        item.isCompleted.toggle()
        #expect(item.isCompleted == false)
    }

    // MARK: - ChecklistSession

    @Test func sessionDefaultValues() {
        let session = ChecklistSession()
        context.insert(session)
        #expect(session.checklist == nil)
        #expect(session.sessionItems?.isEmpty == true)
    }

    @Test func addSessionToChecklist() throws {
        let checklist = Checklist(title: "Morning Routine")
        context.insert(checklist)

        let session = ChecklistSession()
        session.checklist = checklist
        context.insert(session)

        try context.save()

        let sessions = try #require(checklist.sessions)
        #expect(sessions.count == 1)
        #expect(sessions.first?.checklist === checklist)
    }

    @Test func multipleSessionsPerChecklist() throws {
        let checklist = Checklist(title: "Daily Check")
        context.insert(checklist)

        let session1 = ChecklistSession()
        session1.checklist = checklist
        context.insert(session1)

        let session2 = ChecklistSession()
        session2.checklist = checklist
        context.insert(session2)

        try context.save()

        let sessions = try #require(checklist.sessions)
        #expect(sessions.count == 2)
    }

    @Test func cascadeDeleteChecklistRemovesSessions() throws {
        let checklist = Checklist(title: "To delete")
        context.insert(checklist)

        let session = ChecklistSession()
        session.checklist = checklist
        context.insert(session)

        let sessionItem = SessionItem(title: "Task 1")
        sessionItem.session = session
        context.insert(sessionItem)

        try context.save()

        context.delete(checklist)
        try context.save()

        let remainingSessions = try context.fetch(FetchDescriptor<ChecklistSession>())
        #expect(remainingSessions.isEmpty, "Sessions should be cascade deleted with checklist")

        let remainingItems = try context.fetch(FetchDescriptor<SessionItem>())
        #expect(remainingItems.isEmpty, "Session items should be cascade deleted with checklist")
    }

    // MARK: - SessionItem

    @Test func sessionItemDefaultValues() {
        let sessionItem = SessionItem()
        context.insert(sessionItem)
        #expect(sessionItem.title == "")
        #expect(sessionItem.isCompleted == false)
        #expect(sessionItem.completedAt == nil)
        #expect(sessionItem.session == nil)
    }

    @Test func sessionItemInitWithTitle() {
        let sessionItem = SessionItem(title: "Pack lunch")
        context.insert(sessionItem)
        #expect(sessionItem.title == "Pack lunch")
        #expect(sessionItem.isCompleted == false)
    }

    @Test func addSessionItemToSession() throws {
        let session = ChecklistSession()
        context.insert(session)

        let item = SessionItem(title: "Step 1")
        item.session = session
        context.insert(item)

        try context.save()

        let items = try #require(session.sessionItems)
        #expect(items.count == 1)
        let first = try #require(items.first)
        #expect(first.title == "Step 1")
        #expect(first.session === session)
    }

    @Test func cascadeDeleteSessionRemovesSessionItems() throws {
        let session = ChecklistSession()
        context.insert(session)

        let item1 = SessionItem(title: "Task 1")
        item1.session = session
        context.insert(item1)

        let item2 = SessionItem(title: "Task 2")
        item2.session = session
        context.insert(item2)

        try context.save()
        try #require(session.sessionItems?.count == 2)

        context.delete(session)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<SessionItem>())
        #expect(remaining.isEmpty)
    }

    @Test func toggleSessionItemSetsCompletedAt() {
        let sessionItem = SessionItem(title: "Test task")
        context.insert(sessionItem)

        #expect(sessionItem.completedAt == nil)

        sessionItem.isCompleted = true
        sessionItem.completedAt = .now

        #expect(sessionItem.isCompleted == true)
        #expect(sessionItem.completedAt != nil)
    }

    @Test func uncheckSessionItemClearsCompletedAt() {
        let sessionItem = SessionItem(title: "Test task")
        context.insert(sessionItem)

        sessionItem.isCompleted = true
        sessionItem.completedAt = .now
        #expect(sessionItem.completedAt != nil)

        sessionItem.isCompleted = false
        sessionItem.completedAt = nil
        #expect(sessionItem.completedAt == nil)
        #expect(sessionItem.isCompleted == false)
    }
}
