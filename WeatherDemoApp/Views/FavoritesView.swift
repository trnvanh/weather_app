//
//  FavoritesView.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var forecastManager: ForecastManager
    
    @Binding var weather: ResponseBody
    
    var body: some View {
        ZStack {
            // Full-screen gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue, .indigo]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                // Delete All button
                Button(action: {
                    favoritesManager.clearAll()
                }) {
                    Text("Delete All")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 40)
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)
                
                if favoritesManager.favoriteCities.isEmpty {
                    Spacer()
                    Text("No favorites yet")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.title3)
                    Spacer()
                } else {
                    List {
                        ForEach(favoritesManager.favoriteCities, id: \.id) { favorite in
                            FavoriteRow(favorite: favorite)
                                .listRowBackground(Color.clear)

                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let city = favoritesManager.favoriteCities[index]
                                favoritesManager.remove(cityName: city.name)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden) // hide default list background
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    FavoritesView(weather: .constant(previewWeather))
        .environmentObject(WeatherManager())
        .environmentObject(FavoritesManager())
        .environmentObject(ForecastManager())
}

