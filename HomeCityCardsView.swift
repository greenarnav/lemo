//
//  HomeCityCardsView.swift
//  MoodGpt
//
//  Created by Test on 5/7/25.
//


// HomeCityCardsView.swift
import SwiftUI

struct HomeCityCardsView: View {
    let cities: [CitySentiment]
    let currentPage: Int
    let totalPages: Int
    let onPreviousPage: () -> Void
    let onNextPage: () -> Void
    let onToggleFavorite: (CitySentiment) -> Void
    let isFavorite: (CitySentiment) -> Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("City Sentiments").font(.headline).foregroundColor(.white)
                Spacer()
                if !cities.isEmpty {
                    Text("\(currentPage + 1) of \(totalPages)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal)
            
            if cities.isEmpty {
                Text("No cities match your search")
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(cities) { city in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(city.emoji).font(.largeTitle)
                                    Spacer()
                                    Button(action: {
                                        onToggleFavorite(city)
                                    }) {
                                        Image(systemName: isFavorite(city) ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(city.city).bold().foregroundColor(.white)
                                    Text(city.label).foregroundColor(.white.opacity(0.8))
                                    ProgressView(value: city.intensity)
                                        .progressViewStyle(LinearProgressViewStyle(tint: EmotionTheme.cardColor(for: city.label)))
                                }
                            }
                            .padding()
                            .frame(width: 180, height: 160)
                            .background(
                                LinearGradient(
                                    colors: [EmotionTheme.cardColor(for: city.label).opacity(0.6), .black.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Page controls
                HStack {
                    Button(action: onPreviousPage) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(currentPage == 0)
                    Spacer()
                    Button(action: onNextPage) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(currentPage >= totalPages - 1)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
            }
        }
    }
}