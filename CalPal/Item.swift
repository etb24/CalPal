//
//  Item.swift
//  CalPal
//
//  Created by Ethan Bonato on 2025-08-19.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
