//
//  ItemRow.swift
//  Nestmark
//
//  Created by James Plank on 09/05/2026.
//

import SwiftUI

struct ItemRow: View {
    var item: Item

    var body: some View {
        Text(item.title)
    }
}
