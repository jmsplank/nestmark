//
//  SessionItem.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import Foundation
import SwiftData

@Model
final class SessionItem {
    var title: String = ""
    var isCompleted: Bool = false
    var timestamp: Date = Date.now
    var completedAt: Date?
    var session: ChecklistSession?

    init(title: String = "", isCompleted: Bool = false, timestamp: Date = .now) {
        self.title = title
        self.isCompleted = isCompleted
        self.timestamp = timestamp
    }
}
