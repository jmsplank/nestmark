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
}

enum ItemMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ItemSchemaV1.self, ItemSchemaV2.self, ItemSchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: ItemSchemaV1.self,
        toVersion: ItemSchemaV2.self
    )

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: ItemSchemaV2.self,
        toVersion: ItemSchemaV3.self
    )
}
