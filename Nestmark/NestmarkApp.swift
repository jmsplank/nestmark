//
//  NestmarkApp.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI
import SwiftData

@main
struct NestmarkApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Checklist.self,
            ChecklistEntry.self,
            SessionChecklist.self,
            SessionEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: MigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
