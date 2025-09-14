//
//  DailyCard.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import SwiftUI

struct DailyCard: View {
    var day: Date
    var avgTemp: Double
    var icon: String
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(day.formatted(.dateTime.weekday()))
                .font(.caption).bold()
                .foregroundStyle(.white)
            
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { img in
                img.resizable().scaledToFit().frame(width: 40, height: 40)
            } placeholder: {
                ProgressView()
            }
            
            Text("\(avgTemp.roundDouble())°")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(isSelected ? Material.regular : Material.ultraThinMaterial)
        .cornerRadius(16)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    DailyCard(day: Date(), avgTemp: 25, icon: "01d", isSelected: false, onTap: {})
}
