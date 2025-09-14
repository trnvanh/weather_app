//
//  CitySearchManager.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import Foundation

class CitySearchManager: ObservableObject {
    @Published var searchResults: [City] = []
    
    private let apiKey = "d4f8ba3b8cfb0dfbafd0ea52b29a3e2f"
    
    func searchCity(query: String) async {
        guard !query.isEmpty else {
            DispatchQueue.main.async { self.searchResults = [] }
            return
        }
        
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(queryEncoded)&limit=10&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let cities = try JSONDecoder().decode([City].self, from: data)
            
            DispatchQueue.main.async {
                self.searchResults = cities
            }
        } catch {
            print("City search error: \(error)")
        }
    }
}


struct City: Decodable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    
    private enum CodingKeys: String, CodingKey {
            case name, lat, lon, country
    }
}
