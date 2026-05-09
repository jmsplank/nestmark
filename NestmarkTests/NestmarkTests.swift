//
//  NestmarkTests.swift
//  NestmarkTests
//
//  Created by James Plank on 09/05/2026.
//

import Testing
import SwiftData
@testable import Nestmark

@Suite("Model Tests")
struct ModelTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Checklist.self, Item.self, configurations: config)
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
}
