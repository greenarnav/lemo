//
//  HomeMoodForecast.swift
//  MoodGpt
//
//  Created by Test on 5/7/25.
//


// HomeForecastService.swift
import SwiftUI
import Combine

struct HomeMoodForecast: Identifiable {
    let id = UUID()
    let day: String
    let emoji: String
    let label: String
    let isToday: Bool
}

class HomeForecastService: ObservableObject {
    @Published var forecast: [HomeMoodForecast] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    // DataFetcher would be your API service class
    private let dataFetcher: DataFetcher
    
    init(dataFetcher: DataFetcher = DataFetcher.shared) {
        self.dataFetcher = dataFetcher
    }
    
    func fetchForecast(for city: String) {
        isLoading = true
        error = nil
        
        // Replace this with your actual API call
        dataFetcher.fetchMoodForecast(city: city) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let forecasts):
                    self.forecast = forecasts.map { forecast in
                        let isToday = self.isToday(dayString: forecast.day)
                        return HomeMoodForecast(
                            day: forecast.day,
                            emoji: forecast.emoji,
                            label: forecast.label,
                            isToday: isToday
                        )
                    }
                case .failure(let err):
                    self.error = err.localizedDescription
                    // Provide fallback data if API fails
                    self.provideFallbackData()
                }
            }
        }
    }
    
    private func isToday(dayString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let today = formatter.string(from: Date())
        return dayString == today
    }
    
    private func provideFallbackData() {
        // Fallback data in case API fails
        self.forecast = [
            HomeMoodForecast(day: "Mon", emoji: "😌", label: "Calm", isToday: false),
            HomeMoodForecast(day: "Tue", emoji: "😐", label: "Neutral", isToday: false),
            HomeMoodForecast(day: "Wed", emoji: "😀", label: "Joyful", isToday: false),
            HomeMoodForecast(day: "Thu", emoji: "😊", label: "Joyful", isToday: false),
            HomeMoodForecast(day: "Fri", emoji: "😍", label: "Excited", isToday: true),
            HomeMoodForecast(day: "Sat", emoji: "😎", label: "Confident", isToday: false),
            HomeMoodForecast(day: "Sun", emoji: "😌", label: "Calm", isToday: false)
        ]
    }
}