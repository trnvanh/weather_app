//
//  WelcomeView.swift
//  WeatherDemoApp
//
//  Created by Tran Van Anh on 13.9.2025.
//

import SwiftUI
import CoreLocationUI

struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                GifView(gifName: "welcome")
                                .ignoresSafeArea()
                Text("What's the weather like today?")
                    .bold().font(.title)
                Text("Please share your location to start").padding()
            }
            .multilineTextAlignment(.center)
            .padding(.top, 20)
            
            LocationButton(.shareCurrentLocation) {
                locationManager.requestLocation()
            }
            .cornerRadius(30)
            .symbolVariant(.fill)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomeView()
}
