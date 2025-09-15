//
//  ActivityView.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import SwiftUI
import Charts

struct ActivityView: View {
    @EnvironmentObject var forecastManager: ForecastManager

    @AppStorage("selectedCity") private var selectedCityData: Data?
    
    @StateObject private var activityManager: ActivityManager
    
    init() {
        _activityManager = StateObject(wrappedValue: ActivityManager(forecastManager: ForecastManager()))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: City name
                if let city = selectedCityData.flatMap(City.from) {
                    Text("Weather Activity \(city.name)")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
                
                // MARK: Mix chart for temperature and humidity
                if !activityManager.forecast.list.isEmpty {
                    Chart {
                        ForEach(activityManager.groupedByDay(), id: \.key) {day, entries in
                            let avgTemp = activityManager.avgTemp(entries: entries)
                            LineMark(
                                x: .value("Day", day, unit: .day),
                                y: .value("Avg Temp", avgTemp)
                            )
                            .foregroundStyle(.yellow)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .symbol(Circle())
                        }
                    }
                    .chartYScale(domain: 0...40)
                    .frame(height: 200)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                }
                
                // MARK: Recommendations
                VStack(alignment: .leading, spacing: 12) {
                    if activityManager.recommendations.isEmpty {
                        Text("No alerts for today")
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        ForEach(activityManager.recommendations) { tip in
                            HStack {
                                Image(systemName: tip.icon)
                                    .foregroundColor(.yellow)
                                Text(tip.message)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                // MARK: Weekly summary cards
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Overview")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                    
                    ForEach(activityManager.groupedByDay(), id: \.key) { day, entries in
                        HStack {
                            // Day
                            Text(day, style: .date)
                                .foregroundColor(.white)
                                .frame(width: 200, alignment: .leading)
                            
                            // Icon
                            if let icon = entries.first?.weather.first?.icon {
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
                            
                            Spacer()
                            
                            // Avg temp
                            Text("\(activityManager.avgTemp(entries: entries).roundDouble())°")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .indigo]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
        )
        .onAppear {
            Task {
                await activityManager.fetchForecast()
            }
        }
        .onChange(of: selectedCityData) { _ in
            Task {
                await activityManager.fetchForecast()
            }
        }
    }
}

#Preview {
    ActivityView()
        .environmentObject(ForecastManager())
}
