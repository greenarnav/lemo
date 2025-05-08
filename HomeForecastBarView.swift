//
//  HomeForecastBarView.swift
//  MoodGpt
//
//  Created by Test on 5/7/25.
//


// HomeForecastBarView.swift
import SwiftUI

struct HomeForecastBarView: View {
    @ObservedObject var forecastService: HomeForecastService
    let cityName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("7-Day Mood Forecast")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if forecastService.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 100)
            } else if let error = forecastService.error {
                Text("Failed to load forecast: \(error)")
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(forecastService.forecast) { mood in
                            VStack(spacing: 4) {
                                Text(mood.day).font(.caption).fontWeight(mood.isToday ? .bold : .regular)
                                Text(mood.emoji).font(.title2)
                                Text(mood.label).font(.caption2)
                            }
                            .frame(width: 72, height: 100)
                            .background(mood.isToday ? Color.white.opacity(0.25) : Color.white.opacity(0.15))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            forecastService.fetchForecast(for: cityName)
        }
    }
}