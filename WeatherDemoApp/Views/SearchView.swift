//
//  SearchView.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//


import SwiftUI

struct SearchView: View {
    @Binding var selectedCity: City?
    @Environment(\.dismiss) var dismiss
    
    @State private var query: String = ""
    @StateObject private var citySearchManager = CitySearchManager()
    
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var forecastManager: ForecastManager
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    TextField("Search city...", text: $query)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    if !query.isEmpty {
                        Button(action: {
                            Task {
                                await citySearchManager.searchCity(query: query)
                            }
                        }) {
                            Text("Search")
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
                // Search results
                ScrollView {
                    VStack(alignment: .leading) {
                        if citySearchManager.searchResults.isEmpty && !query.isEmpty {
                            Text("No results found")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        
                        ForEach(citySearchManager.searchResults) { city in
                            Button(action: {
                                selectedCity = city
                                dismiss()
                            }) {
                                HStack {
                                    Text("\(city.name), \(city.country)")
                                        .padding(.vertical, 8)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Search City")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchView(selectedCity: .constant(nil))
}
