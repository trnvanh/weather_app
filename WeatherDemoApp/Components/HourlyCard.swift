//
//  HourlyCard.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 14.9.2025.
//

import SwiftUI

struct HourlyCard: View {
    var date: Date
    var temp: Double
    var icon: String
    var description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(date.formatted(.dateTime.hour().minute()))
                .frame(width: 60, alignment: .leading)
            
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { img in
                img.resizable().scaledToFit().frame(width: 30, height: 30)
            } placeholder: {
                Color.gray.frame(width: 30, height: 30)
            }
            
            Text("\(temp.roundDouble())°")
                .bold()
                .frame(width: 50, alignment: .leading)
            
            Text(description.capitalized)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    HourlyCard(date: Date(), temp: 16, icon: "01d", description: "Rain")
}
