//
//  Checklist+Operations.swift
//  Nestmark
//
//  Created by James Plank on 11/05/2026.
//

import Foundation
import SwiftData
import SwiftUI

extension Checklist {
    var sortedEntries: [ChecklistEntry] {
        entries.sorted { $0.position < $1.position }
    }

    func insert(_ entry: ChecklistEntry, at index: Int) {
        let sorted = entries.sorted { $0.position < $1.position }
        for sibling in sorted[index...] {
            sibling.position += 1
        }
        entry.position = index
        entry.checklist = self
    }

    func remove(_ entry: ChecklistEntry, from context: ModelContext) {
        let removed = entry.position
        context.delete(entry)
        for sibling in entries where sibling.position > removed {
            sibling.position -= 1
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        var sorted = entries.sorted { $0.position < $1.position }
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, entry) in sorted.enumerated() {
            entry.position = index
        }
    }
}
