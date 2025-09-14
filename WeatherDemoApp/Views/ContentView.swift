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
    
    @State var weather:ResponseBody?

    @State var forecast:ForecastResponseBody?
    
    @State private var selectedCity: City? = nil
    @State private var currentWeather: ResponseBody = previewWeather
    
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var forecastManager = ForecastManager()
    
    var body: some View {
        Group {
            if let location = locationManager.location {
                TabView {
                    // WeatherView
                    VStack {
                        if let weather = weather {
                            WeatherView(weather: weather)
                        } else {
                            LoadingView()
                                .task {
                                    do {
                                        weather = try await
                                        weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                                        
                                    } catch {
                                        print("Error getting weather: \(error)")
                                    }
                                }
                            
                            
                        }
                    }
                    .tabItem{
                        Label("Weather", systemImage: "cloud.sun.fill")
                    }
                    
                    // ForecastView
                    VStack {
                        if let forecast = forecast {
                            ForecastView(forecast: forecast)
                        } else {
                            LoadingView()
                                .task {
                                    do {
                                        
                                            forecast = try await
                                            forecastManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                                        
                                    } catch {
                                        print("Error getting weather forecast: \(error)")
                                    }
                                }
                        }
                    }
                    .tabItem{
                        Label("Forecast", systemImage: "calendar")
                    }
                    
                    // FavoritesView
                    FavoritesView(selectedCity: $selectedCity, weather: $currentWeather).tabItem {
                        Label("Favorites", systemImage: "bookmark.fill")
                    }
                    
                    // AvtivityView
                    ActivityView().tabItem {
                        Label("Activity", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
                .tint(.blue)
                .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354, opacity: 1))
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView().environmentObject(locationManager)
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .indigo]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing))
        .preferredColorScheme(.dark)
        .environmentObject(favoritesManager)
        .environmentObject(weatherManager)
        .environmentObject(forecastManager)
    }
    
}
    


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
