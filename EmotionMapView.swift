// EmotionMapView.swift
// MoodGpt
//
// Created by Test on 5/7/25.
//

import SwiftUI
import MapKit
import CoreLocation

// Our custom city emotion data model to avoid conflicting with existing CityEmotion
struct MapCityEmotion: Identifiable {
    let id = UUID()
    let cityName: String
    let coordinate: CLLocationCoordinate2D
    let emoji: String
    let sentiment: String
}

// Component for the Map itself
struct EmotionMapView: View {
    @Binding var region: MKCoordinateRegion
    let cityEmotions: [MapCityEmotion]
    @Binding var userInteractedWithMap: Bool
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: cityEmotions) { city in
            MapAnnotation(coordinate: city.coordinate) {
                CityMarker(cityData: city)
                    .onTapGesture {
                        // When a city annotation is tapped, center the map on it
                        withAnimation {
                            region.center = city.coordinate
                            userInteractedWithMap = true
                        }
                    }
            }
        }
        .ignoresSafeArea()
        // Add gesture recognizers to detect user interaction with the map
        .gesture(
            DragGesture().onChanged { _ in
                userInteractedWithMap = true
            }
        )
        .gesture(
            MagnificationGesture().onChanged { _ in
                userInteractedWithMap = true
            }
        )
    }
}

// Component for each city's marker on the map
struct CityMarker: View {
    let cityData: MapCityEmotion
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                
                Text(cityData.emoji)
                    .font(.system(size: 24))
            }
            
            Text(cityData.cityName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.9))
                .cornerRadius(4)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
    }
}

// Location button in bottom right corner
struct MapLocationButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                }
                .padding([.trailing, .bottom], 16)
            }
        }
    }
}

// Loading indicator
struct MapLoadingIndicator: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.5)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
    }
}
