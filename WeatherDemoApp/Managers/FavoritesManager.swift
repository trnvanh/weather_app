//
//  FavoriteManager.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favoriteCities: [City] = [] {
        didSet {saveFavorites()}
    }
    
    private let favoritesKey = "favorites"
    
    init() {
            loadFavorites()
    }
    
    func add(city: City) {
        if !favoriteCities.contains(where: { $0.name == city.name }) {
            favoriteCities.append(city)
        }
    }
    
    func remove(cityName: String) {
        favoriteCities.removeAll { $0.name == cityName }
    }
    
    func isFavorite(cityName: String) -> Bool {
        favoriteCities.contains (where: { $0.name == cityName })
    }
    
    func clearAll() {
        favoriteCities.removeAll()
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteCities) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([City].self, from: data) {
            favoriteCities = decoded
        }
    }
}
