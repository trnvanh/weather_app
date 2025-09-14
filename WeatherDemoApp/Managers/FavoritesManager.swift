//
//  FavoriteManager.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteCities: [City] = []
    
    func add(city: City) {
        if !favoriteCities.contains(where: { $0.name == city.name }) {
            favoriteCities.append(city)
        }
    }
    
    func remove(cityName: String) {
        favoriteCities.removeAll { $0.name == cityName }
    }
    
    func isFavorite(cityName: String) -> Bool {
        favoriteCities.contains { $0.name == cityName }
    }
    
    func clearAll() {
        favoriteCities.removeAll()
    }
}
