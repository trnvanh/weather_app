//
//  FavoriteCard.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 15.9.2025.
//

import SwiftUI

struct FavoriteRow: View {
    let favorite: City
    let onSelect: (ResponseBody) -> Void
    
    @State private var weather: ResponseBody? = nil
    @EnvironmentObject var weatherManager: WeatherManager
    
    
    var body: some View {
        Button {
            Task {
                if let weather = weather {
                    onSelect(weather)
                } else {
                    do {
                        let fetchedWeather = try await weatherManager.getCurrentWeather(latitude: favorite.lat, longitude: favorite.lon)
                        await MainActor.run {
                            self.weather = fetchedWeather
                            onSelect(fetchedWeather)
                        }
                    } catch {
                        print("Failed to fetch weather for \(favorite.name): \(error)")
                    }
                }
            }
        } label: {
            HStack(spacing: 16) {
                if let icon = weather?.weather.first?.icon {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(weather?.sys.country ?? favorite.country)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text(weather != nil ? "\(weather!.main.temp.roundDouble())°" : "--°")
                    .font(.title3).bold()
                    .foregroundColor(.white)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
    }
    
    func fetchWeather() async {
        do {
            let fetchedWeather = try await weatherManager.getCurrentWeather(latitude: favorite.lat, longitude: favorite.lon)
            await MainActor.run {
                self.weather = fetchedWeather
            }
        } catch {
            print("Failed to fetch weather for \(favorite.name): \(error)")
        }
    }
}
