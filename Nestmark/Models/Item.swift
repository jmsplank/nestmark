//
//  Item.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String = ""
    var isCompleted: Bool = false
    var completedAt: Date?
    var checklist: Checklist?

    init(title: String = "", isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}
