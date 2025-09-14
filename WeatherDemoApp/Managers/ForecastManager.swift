//
//  ForecastManager.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import Foundation
import CoreLocation

class ForecastManager : ObservableObject {
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ForecastResponseBody {
        guard let url = URL(string:"https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\("d4f8ba3b8cfb0dfbafd0ea52b29a3e2f")&units=metric") else {fatalError("Missing URL")}
        
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error fetching weather data")
        }
        
        let decodedForecastData = try JSONDecoder().decode(ForecastResponseBody.self, from: data)
        
        return decodedForecastData
    }
}

// Model of the response body from calling the OpenWeather API for forecast
struct ForecastResponseBody: Decodable {
    var list: [ForecastEntry]
    var city: CityResponse

    struct ForecastEntry: Decodable, Identifiable{
        var id: Int { dt }
        var dt: Int
        var main: MainResponse
        var weather: [WeatherResponse]
        var wind: WindResponse
        var dt_txt: String

        // Convert timestamp into Swift Date
        var date: Date {
            Date(timeIntervalSince1970: TimeInterval(dt))
        }
    }

    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }

    struct WeatherResponse: Decodable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }

    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }

    struct CityResponse: Decodable {
        var name: String
        var country: String
    }
}

