//
//  ItemMigrationPlan.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import Foundation
import SwiftData

enum ItemSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] { [Item.self] }

    @Model
    final class Item {
        var timestamp: Date

        init(timestamp: Date) {
            self.timestamp = timestamp
        }
    }
}

enum ItemSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }

    static var models: [any PersistentModel.Type] { [Item.self] }

    @Model
    final class Item {
        var title: String = ""
        var isCompleted: Bool = false
        var timestamp: Date = Date.now

        init(title: String = "", isCompleted: Bool = false, timestamp: Date = .now) {
            self.title = title
            self.isCompleted = isCompleted
            self.timestamp = timestamp
        }
    }
}

enum ItemSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(3, 0, 0) }

    static var models: [any PersistentModel.Type] { [Item.self, Checklist.self] }

    @Model
    final class Item {
        var title: String = ""
        var isCompleted: Bool = false
        var timestamp: Date = Date.now
        var checklist: Checklist?

        init(title: String = "", isCompleted: Bool = false, timestamp: Date = .now) {
            self.title = title
            self.isCompleted = isCompleted
            self.timestamp = timestamp
        }
    }

    @Model
    final class Checklist {
        var title: String = ""
        var timestamp: Date = Date.now

        @Relationship(deleteRule: .cascade, inverse: \Item.checklist)
        var items: [Item]? = []

        init(title: String = "", timestamp: Date = .now) {
            self.title = title
            self.timestamp = timestamp
        }
    }
}

enum ItemSchemaV4: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(4, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [Item.self, Checklist.self, ChecklistSession.self, SessionItem.self]
    }

    @Model
    final class Item {
        var title: String = ""
        var isCompleted: Bool = false
        var timestamp: Date = Date.now
        var checklist: Checklist?

        init(title: String = "", isCompleted: Bool = false, timestamp: Date = .now) {
            self.title = title
            self.isCompleted = isCompleted
            self.timestamp = timestamp
        }
    }

    @Model
    final class Checklist {
        var title: String = ""
        var timestamp: Date = Date.now

        @Relationship(deleteRule: .cascade, inverse: \Item.checklist)
        var items: [Item]? = []

        @Relationship(deleteRule: .cascade, inverse: \ChecklistSession.checklist)
        var sessions: [ChecklistSession]? = []

        init(title: String = "", timestamp: Date = .now) {
            self.title = title
            self.timestamp = timestamp
        }
    }

    @Model
    final class ChecklistSession {
        var timestamp: Date = Date.now
        var checklist: Checklist?

        @Relationship(deleteRule: .cascade, inverse: \SessionItem.session)
        var sessionItems: [SessionItem]? = []

        init(timestamp: Date = .now) {
            self.timestamp = timestamp
        }
    }

    @Model
    final class SessionItem {
        var title: String = ""
        var isCompleted: Bool = false
        var timestamp: Date = Date.now
        var session: ChecklistSession?

        init(title: String = "", isCompleted: Bool = false, timestamp: Date = .now) {
            self.title = title
            self.isCompleted = isCompleted
            self.timestamp = timestamp
        }
    }
}

enum ItemSchemaV5: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(5, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [Item.self, Checklist.self, ChecklistSession.self, SessionItem.self]
    }
}

enum ItemMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ItemSchemaV1.self, ItemSchemaV2.self, ItemSchemaV3.self, ItemSchemaV4.self, ItemSchemaV5.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3, migrateV3toV4, migrateV4toV5]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: ItemSchemaV1.self,
        toVersion: ItemSchemaV2.self
    )

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: ItemSchemaV2.self,
        toVersion: ItemSchemaV3.self
    )

    static let migrateV3toV4 = MigrationStage.lightweight(
        fromVersion: ItemSchemaV3.self,
        toVersion: ItemSchemaV4.self
    )

    static let migrateV4toV5 = MigrationStage.lightweight(
        fromVersion: ItemSchemaV4.self,
        toVersion: ItemSchemaV5.self
    )
}
