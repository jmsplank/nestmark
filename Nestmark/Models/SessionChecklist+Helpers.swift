//
//  SessionChecklist+Helpers.swift
//  Nestmark
//
//  Created by James Plank on 11/05/2026.
//

import Foundation

extension SessionChecklist {
    var totalEntries: Int {
        (entries ?? []).count
    }
    var completedCount: Int {
        (entries ?? []).count(where: \.isComplete)
    }
}
