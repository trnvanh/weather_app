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
    
    @State private var weather: ResponseBody? = previewWeather
    
    @AppStorage("selectedCity") private var selectedCityData: Data?
    
    var body: some View {
        Button {
            Task {
                do {
                    // Fetch latest weather and forecast
                    let fetchedWeather = try await weatherManager.getCurrentWeather(
                        latitude: favorite.lat,
                        longitude: favorite.lon
                    )
                    let fetchedForecast = try await forecastManager.getCurrentWeather(
                        latitude: favorite.lat,
                        longitude: favorite.lon
                    )
                    
                    // Update FavoritesManager (persistent storage)
                    await MainActor.run {
                        self.weather = fetchedWeather
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
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                } else {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
                
                // City info
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(weather?.sys.country ?? favorite.country)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Temperature
                Text(weather != nil ? "\(weather!.main.temp.roundDouble())°" : "--°")
                    .font(.title3).bold()
                    .foregroundColor(.white)
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
            // Pre-fetch weather for smooth UI
            if weather == nil {
                await fetchWeather()
            }
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

// Preview
#Preview {
    let favoritesManager = FavoritesManager()
    favoritesManager.favoriteCities = [
        City(name: "Helsinki", lat: 60.1699, lon: 24.9384, country: "FI"),
        City(name: "Tampere", lat: 61.4981, lon: 23.7610, country: "FI")
    ]
    
    return VStack {
        ForEach(favoritesManager.favoriteCities, id: \.id) { city in
            FavoriteRow(favorite: city)
                .environmentObject(WeatherManager())
                .environmentObject(ForecastManager())
                .environmentObject(favoritesManager)
        }
    }
    .background(
        LinearGradient(gradient: Gradient(colors: [.blue, .indigo]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    )
}

