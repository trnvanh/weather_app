# SkyCast

SkyCast is a modern, visually appealing weather application that provides real-time weather updates, forecasts, and personalized recommendations for users. The app is designed to help users stay prepared for daily weather conditions, with intuitive UI and interactive features. This is my first practice app to learn Swift.

## Features

### 1. Current Weather

Displays the current weather for your location or a selected city.

Shows temperature, humidity, wind speed, and weather condition.

Dynamic background and animations depending on weather (sun, rain, snow).

### 2. Forecast

5-day forecast with daily and hourly views.

Interactive horizontal cards for daily weather.

Detailed hourly breakdown for each selected day.

### 3. Favorites

Add and remove cities from favorites.

Swipe to delete individual favorite cities.

Persistent storage ensures favorites remain across sessions.

### 4. Activity

Visual graphs showing temperature trends and weather indexes.

Weekly summary cards for a quick overview.

Personalized recommendations based on weather. For example: if it's raining>50%, suggest user to bring an umbrella when going out

Alerts for rain or severe weather conditions.

### 5. Search

Search for any city worldwide.

Instant update of weather and forecast when selecting a city.

## Technology

Frontend: SwiftUI

Backend: Swift

API: Openweathermap API for weather, forecast, and geo

## Installation

- Clone the repository: git clone https://github.com/yourusername/SkyCast.git

- Open SkyCast.xcodeproj in Xcode.

- Add your OpenWeatherMap API key in WeatherManager.swift and ForecastManager.swift.

- Build and run on a simulator or device.

## App Architecture
- WeatherManager: Handles fetching and storing current weather data for a given location or city.
- ForecastManager: Fetches and manages forecast data (hourly/daily).
- LocationManager: Tracks and provides the user’s current location.
- ActivityManager: Processes forecast data to generate activity insights and charts.
- CitySearchManager: Handles city search functionality and stores search results.
- FavoritesManager: Stores and manages user favorite cities.
