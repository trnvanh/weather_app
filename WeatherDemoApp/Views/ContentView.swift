//
//  ContentView.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 13.9.2025.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    
    @State private var weather: ResponseBody = previewWeather
    @State private var forecast: ForecastResponseBody = previewForecast
    
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var forecastManager = ForecastManager()
    
    @AppStorage("selectedCity") private var selectedCityData: Data?
    var selectedCity: City? {
        get { selectedCityData.flatMap(City.from) }
        set { selectedCityData = newValue?.toData() }
    }
    
    var body: some View {
        Group {
            if let location = locationManager.location {
                TabView {
                    // MARK: Weather tab
                    WeatherView(weather: $weather, forecast: $forecast)
                        .tabItem {
                            Label("Weather", systemImage: "cloud.sun.fill")
                        }
                    
                    // MARK: Forecast tab
                    ForecastView(forecast: $forecast)
                        .tabItem {
                            Label("Forecast", systemImage: "calendar")
                        }
                    
                    // MARK: Favorites tab
                    FavoritesView(weather: $weather)
                        .tabItem {
                            Label("Favorites", systemImage: "bookmark.fill")
                        }
                    
                    // MARK: Activity tab
                    ActivityView()
                        .tabItem {
                            Label("Activity", systemImage: "arrow.triangle.2.circlepath")
                        }
                }
                .tint(.blue)
                .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354, opacity: 1))
                .task {
                    await fetchWeatherAndForecast(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    
                }
                .onChange(of: selectedCity) { newCity in
                    guard let city = newCity else { return }
                    Task {
                        await fetchWeatherAndForecast(latitude: city.lat, longitude: city.lon)
                    }
                }
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView().environmentObject(locationManager)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue, .indigo]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(.dark)
        .environmentObject(favoritesManager)
        .environmentObject(weatherManager)
        .environmentObject(forecastManager)
    }
    
    // MARK: - Helper function
    func fetchWeatherAndForecast(latitude: Double, longitude: Double) async {
        do {
            let newWeather = try await weatherManager.getCurrentWeather(latitude: latitude, longitude: longitude)
            let newForecast = try await forecastManager.getCurrentWeather(latitude: latitude, longitude: longitude)
            await MainActor.run {
                weather = newWeather
                forecast = newForecast
            }
        } catch {
            print("❌ Error fetching weather or forecast: \(error)")
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
