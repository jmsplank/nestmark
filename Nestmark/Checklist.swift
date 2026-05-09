//
//  Checklist.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import Foundation
import SwiftData

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
