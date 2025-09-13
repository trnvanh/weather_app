//
//  Item.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 13.9.2025.
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
