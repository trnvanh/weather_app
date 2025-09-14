//
//  WeatherView.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 13.9.2025.
//

import SwiftUI

struct WeatherView: View {
    @State var weather: ResponseBody
    
    @State private var showSearch: Bool = false
    @State private var selectedCity: City? = nil
    
    @EnvironmentObject var weatherManager: WeatherManager
    
    @EnvironmentObject var forecastManager: ForecastManager
    
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @StateObject private var citySearchManager = CitySearchManager()
    
    var backgroundURL: URL {
        return URL(string: "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&q=60&w=1600")!
    }
    
    var isFavorite: Bool {
            favoritesManager.isFavorite(cityName: weather.name)
    }
    
    var body: some View {
        ZStack {
            AsyncImage(url: backgroundURL) {image in image.resizable()
                    .blur(radius: 10)
                    .overlay(Color.black.opacity(0.3))
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            } placeholder: {
                Color.clear.ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    Text("Search...")
                    
                    Spacer()
                    
                    Button(action: {
                        showSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                    }
                    .sheet(isPresented: $showSearch) {
                                SearchView(selectedCity: $selectedCity)
                                    .environmentObject(citySearchManager)
                    }
                    .onChange(of: selectedCity) { newCity in
                        if let city = newCity {
                            Task {
                                do {
                                    let newWeather = try await weatherManager.getCurrentWeather(
                                        latitude: city.lat,
                                        longitude: city.lon
                                    )
                                    let newForecast = try await forecastManager.getCurrentWeather(
                                        latitude: city.lat,
                                        longitude: city.lon
                                    )
                                    await MainActor.run {
                                        self.weather = newWeather
                                    }
                                } catch {
                                    print("Failed to fetch weather for \(city.name): \(error)")
                                }
                            }
                        }
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                HStack(spacing: 20) {
                    // City and date time
                    VStack(alignment: .leading, spacing: 5) {
                        Text(weather.name).bold().font(.largeTitle).shadow(radius: 5)
                        Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))").fontWeight(.light)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Button to add city to Favorites
                    Button(action: {
                        if isFavorite {
                            favoritesManager.remove(cityName: weather.name)
                        } else {
                            favoritesManager.add(city: City(name: weather.name, lat: weather.coord.lat, lon: weather.coord.lon, country: weather.sys.country))
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.largeTitle)
                            .foregroundColor(isFavorite ? .red : .white)
                            .padding(.horizontal,15)
                    }
                }
                
                
                Spacer()
                
                HStack(alignment: .center, spacing: 20) {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .shadow(radius: 10)
                            .modifier(WeatherAnimation(condition: weather.weather[0].main))
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Text("\(weather.main.feels_like.roundDouble())°")
                        .font(.system(size: 80, weight: .bold))
                        .shadow(radius: 10)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(25)
                .padding(.horizontal)
                
                Text(weather.weather[0].main)
                    .font(.title2).bold()
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 10)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weather indexes now")
                        .bold().font(.headline)
                    
                    HStack {
                        WeatherRow(logo: "thermometer.low", name: "Min temp", value:(weather.main.temp_min.roundDouble()+"°"))
                        Spacer()
                        WeatherRow(logo: "thermometer.high", name: "Max temp", value:(weather.main.temp_max.roundDouble()+"°"))
                    }
                    
                    HStack {
                        WeatherRow(logo: "wind", name: "Wind speed", value:(weather.wind.speed.roundDouble()+"m/s"))
                        Spacer()
                        WeatherRow(logo: "humidity", name: "Humidity", value:(weather.main.humidity.roundDouble()+"%"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top,20)
                .padding(.bottom, 20)
                .padding(.horizontal)
                .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                
            }
            
        }
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354, opacity: 1))
        .preferredColorScheme(.dark)
        
    }
        
}


#Preview {
    WeatherView(weather: previewWeather)
        .environmentObject(WeatherManager())
        .environmentObject(CitySearchManager())
        .environmentObject(FavoritesManager())
        .environmentObject(ForecastManager())
}

// Animations depending on weather
struct WeatherAnimation: ViewModifier {
    var condition: String
    
    func body(content: Content) -> some View {
        switch condition.lowercased() {
        case "clear":
            // Sun pulse glow
            content.overlay(
                Circle()
                    .stroke(Color.yellow.opacity(0.6), lineWidth: 15)
                    .scaleEffect(1.2)
                    .blur(radius: 30)
                    .opacity(0.8)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: UUID())
            )
        case "rain":
            // Falling raindrops
            content.overlay(
                RainEffect()
            )
        case "snow":
            // Falling snowflakes
            content.overlay(
                SnowEffect()
            )
        default:
            content
        }
    }
}

// Simple raindrop animation
struct RainEffect: View {
    @State private var dropY: CGFloat = -100
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 3, height: 10)
                    .position(x: CGFloat.random(in: 0...geo.size.width),
                              y: dropY)
                    .animation(
                        .linear(duration: Double.random(in: 1...2))
                        .repeatForever(autoreverses: false),
                        value: dropY
                    )
            }
        }
        .onAppear { dropY = 1000 }
    }
}

// Simple snowflake animation
struct SnowEffect: View {
    @State private var snowY: CGFloat = -50
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: CGFloat.random(in: 5...10))
                    .position(x: CGFloat.random(in: 0...geo.size.width),
                              y: snowY)
                    .animation(
                        .linear(duration: Double.random(in: 5...8))
                        .repeatForever(autoreverses: false),
                        value: snowY
                    )
            }
        }
        .onAppear { snowY = 1000 }
    }
}
