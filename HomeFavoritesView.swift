//
//  HomeFavoritesView.swift
//  MoodGpt
//
//  Created by Test on 5/7/25.
//


// HomeFavoritesView.swift
import SwiftUI

struct HomeFavoritesView: View {
    let favorites: [CitySentiment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorites").font(.headline).foregroundColor(.white).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(favorites) { city in
                        HStack {
                            Text(city.emoji)
                            Text(city.city).font(.subheadline)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(EmotionTheme.cardColor(for: city.label).opacity(0.3))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}