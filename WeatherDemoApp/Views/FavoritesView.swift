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
    
    @Binding var selectedCity: City?
    @Binding var weather: ResponseBody
    
    
    var body: some View {
        NavigationStack
        {
            Button(action: {
                favoritesManager.clearAll()
            }){
                Text("Delete All")
            }.padding(.top,20).background(Color.red).foregroundColor(.white).cornerRadius(10).frame(width: 100, height: 30)
            
            ZStack {
                
                LinearGradient(gradient: Gradient(colors: [.blue, .indigo]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                
                
                
                ScrollView {
                    
                    VStack {
                        if favoritesManager.favoriteCities.isEmpty {
                            Text("No favorites yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(favoritesManager.favoriteCities, id: \.id) { favorite in
                                FavoriteRow(favorite: favorite) { fetchedWeather in
                                    self.weather = fetchedWeather
                                    self.selectedCity = favorite
                                }
                            }
                        }
                    }
                    .padding(.top)
                    
                }
                
                
            }
            
        }
    }
}


#Preview {
    FavoritesView(selectedCity: .constant(nil),
                  weather: .constant(previewWeather))
        .environmentObject(WeatherManager())
        .environmentObject(FavoritesManager())
}
