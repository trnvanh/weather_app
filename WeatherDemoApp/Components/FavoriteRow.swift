//
//  FavoriteCard.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 15.9.2025.
//

import SwiftUI

struct FavoriteRow: View {
    let favorite: City
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var forecastManager: ForecastManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @State private var weather: ResponseBody? = nil
    @AppStorage("selectedCity") private var selectedCityData: Data?
    
    var body: some View {
        Button {
            Task {
                do {
                    // Fetch latest weather for this favorite
                    let fetchedWeather = try await weatherManager.getCurrentWeather(
                        latitude: favorite.lat,
                        longitude: favorite.lon
                    )
                    let _ = try await forecastManager.getCurrentWeather(
                        latitude: favorite.lat,
                        longitude: favorite.lon
                    )
                    
                    // Update this row's weather
                    await MainActor.run {
                        self.weather = fetchedWeather
                        
                        // Save selected city globally
                        if let encodedCity = try? JSONEncoder().encode(favorite) {
                            selectedCityData = encodedCity
                        }
                    }
                } catch {
                    print("Failed to fetch weather for \(favorite.name): \(error)")
                }
            }
        } label: {
            HStack(spacing: 16) {
                // Weather icon
                if let icon = weather?.weather.first?.icon {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView().frame(width: 50, height: 50)
                    }
                } else {
                    ProgressView().frame(width: 50, height: 50)
                }
                
                // City info
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(favorite.country)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Temperature
                if let temp = weather?.main.temp {
                    Text("\(temp.roundDouble())°")
                        .font(.title3).bold()
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(radius: 5)
            .padding(.horizontal)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    withAnimation {
                        favoritesManager.remove(cityName: favorite.name)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .task {
            // Load weather when row appears
            await fetchWeather()
        }
    }
    
    private func fetchWeather() async {
        do {
            let fetchedWeather = try await weatherManager.getCurrentWeather(
                latitude: favorite.lat,
                longitude: favorite.lon
            )
            await MainActor.run {
                self.weather = fetchedWeather
            }
        } catch {
            print("Failed to fetch weather for \(favorite.name): \(error)")
        }
    }
}
