//
//  ActivityManager.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 15.9.2025.
//

import Foundation
import SwiftUI

@MainActor
class ActivityManager: ObservableObject {
    @Published var forecast: ForecastResponseBody = previewForecast
    @Published var recommendations: [WeatherTip] = []
    
    private let forecastManager: ForecastManager
    @AppStorage("selectedCity") private var selectedCityData: Data?
    
    var selectedCity: City? {
        get { selectedCityData.flatMap(City.from) }
    }
    
    init(forecastManager: ForecastManager) {
        self.forecastManager = forecastManager
    }
    
    func fetchForecast() async {
        guard let city = selectedCity else { return }
        do {
            let newForecast = try await forecastManager.getCurrentWeather(
                latitude: city.lat,
                longitude: city.lon
            )
            self.forecast = newForecast
            generateRecommendations()
        } catch {
            print("Failed to fetch forecast for \(city.name): \(error)")
        }
    }
    
    func generateRecommendations() {
        recommendations.removeAll()
        guard let first = forecast.list.first else { return }
        
        if first.main.humidity > 70 {
            recommendations.append(WeatherTip(icon: "drop.fill", message: "High chance of rain today ☔"))
        }
        if first.wind.speed > 10 {
            recommendations.append(WeatherTip(icon: "wind", message: "Windy conditions today 🌬️"))
        }
        if first.main.temp > 30 {
            recommendations.append(WeatherTip(icon: "sun.max.fill", message: "Stay hydrated! High temp 🌞"))
        }
    }
    
    func groupedByDay() -> [(key: Date, value: [ForecastResponseBody.ForecastEntry])] {
        Dictionary(grouping: forecast.list) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        .sorted { $0.key < $1.key }
    }
    
    func avgTemp(entries: [ForecastResponseBody.ForecastEntry]) -> Double {
        entries.map { $0.main.temp }.reduce(0, +) / Double(entries.count)
    }
}

struct WeatherTip: Identifiable {
    var id = UUID()
    var icon: String
    var message: String
}
