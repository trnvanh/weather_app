//
//  ForecastView.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import SwiftUI

struct ForecastView: View {
    @Binding var forecast: ForecastResponseBody
    
    @State private var selectedDay: Date = Date()
    
    @EnvironmentObject var forecastManager: ForecastManager
    
    private var groupedByDate: [Date: [ForecastResponseBody.ForecastEntry]] {
        Dictionary(grouping: forecast.list) {
            entry in Calendar.current.startOfDay(for: entry.date)
        }
    }
    
    private var sortedDays: [Date] {
        groupedByDate.keys.sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 5-day forecast cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(sortedDays, id: \.self) { day in if let entries = groupedByDate[day], !entries.isEmpty
                            {
                            let avgTemp = entries.map{$0.main.temp}.reduce(0, +) / Double(entries.count)
                            let icon = entries.first?.weather.first?.icon ?? "01d"
                            
                            DailyCard(day: day, avgTemp: avgTemp, icon: icon, isSelected: selectedDay == day, onTap: {selectedDay = day})
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    selectedDay = sortedDays.first ?? Date()
                }
                    
                // Hourly forecast for selected day
                if let entries = groupedByDate[selectedDay] {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(entries) { entry in
                            HourlyCard(date: entry.date,
                                       temp: entry.main.temp,
                                       icon: entry.weather.first?.icon ?? "01d",
                                       description: entry.weather.first?.description ?? "")
                        }
                    }
                    .padding(.horizontal)
                }
                    
                // Info indexes card
                if let firstEntry = groupedByDate[selectedDay]?.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Index details").font(.headline).bold()
                        
                        HStack {
                            WeatherRow(logo: "wind", name: "Wind", value: "\(firstEntry.wind.speed.roundDouble()) m/s")
                            Spacer()
                            WeatherRow(logo: "humidity", name: "Humidity", value: "\(firstEntry.main.humidity.roundDouble())%")
                        }
                        
                        HStack {
                            WeatherRow(logo: "thermometer.low", name: "Min temp", value:"\(firstEntry.main.temp_min.roundDouble()+"°")")
                            Spacer()
                            WeatherRow(logo: "thermometer.high", name: "Max temp", value:"\(firstEntry.main.temp_min.roundDouble()+"°")")
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                
            }
            .padding(.vertical)
        }
        .navigationTitle("Forecast")
        .foregroundColor(.white)
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .indigo]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)

        )
        
    }
        
}

#Preview {
    ForecastView(forecast: .constant(previewForecast))
}
