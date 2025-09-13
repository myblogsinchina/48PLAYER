//
//  Item.swift
//  PLAYER48
//
//  Created by USER on 2025/09/13.
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
