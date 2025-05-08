// MapScreen.swift
// MoodGpt
//
// Created by Test on 5/7/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var region = MKCoordinateRegion(
        // Default to New York as a fallback
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var cityEmotions: [MapCityEmotion] = []
    @State private var isLoading = true
    @State private var showPermissionAlert = false
    @State private var userInteractedWithMap = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map with city emotion annotations
                EmotionMapView(
                    region: $region,
                    cityEmotions: cityEmotions,
                    userInteractedWithMap: $userInteractedWithMap
                )
                
                // Location button overlay
                MapLocationButton(action: requestAndCenterOnUserLocation)
                
                // Loading indicator
                if isLoading {
                    MapLoadingIndicator()
                }
            }
            .alert("Location Access Required", isPresented: $showPermissionAlert) {
                Button("Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow location access to see your position on the map and get local sentiment data.")
            }
            .navigationTitle(appState.locationManager.cityName.isEmpty ? "Locating…" : appState.locationManager.cityName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Request location when view appears
                requestAndCenterOnUserLocation()
                loadCityEmotions()
                
                // Monitor authorization status changes
                if appState.locationManager.authorizationStatus == .denied ||
                   appState.locationManager.authorizationStatus == .restricted {
                    showPermissionAlert = true
                }
            }
            // Use the updated onChange syntax for iOS 17
            .onChange(of: appState.locationManager.userLocation) { oldValue, newValue in
                // Only update if we have a new valid location and user hasn't interacted
                if let newLocation = newValue, !userInteractedWithMap {
                    print("New user location received: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
                    withAnimation {
                        region = MKCoordinateRegion(
                            center: newLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
                }
            }
            .onChange(of: appState.locationManager.authorizationStatus) { oldValue, newValue in
                if newValue == .authorizedWhenInUse || newValue == .authorizedAlways {
                    // If authorization just granted, try to get location again
                    requestAndCenterOnUserLocation()
                } else if newValue == .denied || newValue == .restricted {
                    showPermissionAlert = true
                }
            }
        }
    }
    
    // Request and center on user's current location
    private func requestAndCenterOnUserLocation() {
        // Reset the user interaction flag
        userInteractedWithMap = false
        
        // Request location permission
        appState.locationManager.requestLocationPermission()
        
        // Check if we already have a location
        if let location = appState.locationManager.userLocation {
            print("Using existing location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        } else {
            // If no location yet, let the onChange handler update when it arrives
            print("No location available yet, waiting for location update...")
            
            // Default to New York
            withAnimation {
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    // Load city emotion data
    private func loadCityEmotions() {
        isLoading = true
        
        // Just load fallback data for now (we'll skip API calls to simplify)
        loadFallbackEmotions()
    }
    
    // Fallback method with sample data (focusing on New York area)
    private func loadFallbackEmotions() {
        DispatchQueue.main.async {
            // Hardcoded sample data as fallback, focused on New York area
            var emotions = [
                MapCityEmotion(
                    cityName: "New York",
                    coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                    emoji: "😀",
                    sentiment: "positive"
                ),
                MapCityEmotion(
                    cityName: "Brooklyn",
                    coordinate: CLLocationCoordinate2D(latitude: 40.6782, longitude: -73.9442),
                    emoji: "🤩",
                    sentiment: "excited"
                ),
                MapCityEmotion(
                    cityName: "Queens",
                    coordinate: CLLocationCoordinate2D(latitude: 40.7282, longitude: -73.7949),
                    emoji: "🙃",
                    sentiment: "mixed"
                ),
                MapCityEmotion(
                    cityName: "Jersey City",
                    coordinate: CLLocationCoordinate2D(latitude: 40.7178, longitude: -74.0431),
                    emoji: "😌",
                    sentiment: "calm"
                ),
                MapCityEmotion(
                    cityName: "Newark",
                    coordinate: CLLocationCoordinate2D(latitude: 40.7357, longitude: -74.1724),
                    emoji: "🤔",
                    sentiment: "thoughtful"
                )
            ]
            
            // Add random cities/locations to populate the map
            emotions.append(contentsOf: self.generateRandomCityEmotions(count: 20))
            
            self.cityEmotions = emotions
            self.isLoading = false
        }
    }
    
    // Generate random city emotions around the current region
    private func generateRandomCityEmotions(count: Int) -> [MapCityEmotion] {
        var randomEmotions: [MapCityEmotion] = []
        
        // Define possible sentiments and emojis
        let sentiments = ["happy", "sad", "excited", "calm", "nervous", "thoughtful",
                         "angry", "surprised", "loved", "bored", "positive", "mixed", "neutral"]
        let emojis = ["😀", "😢", "😡", "😮", "😍", "🥱", "😱", "🤔", "😌", "🤩", "😎", "🙃", "😐"]
        
        // Get center coordinates (use New York if no user location)
        let centerLat = appState.locationManager.userLocation?.coordinate.latitude ?? 40.7128
        let centerLng = appState.locationManager.userLocation?.coordinate.longitude ?? -74.0060
        
        // Random location names
        let locationPrefixes = ["North", "South", "East", "West", "Upper", "Lower", "Central", "Downtown", "Midtown", "Old"]
        let locationNames = ["Village", "Heights", "Park", "Square", "District", "Crossing", "Gardens", "Point", "Hills", "Valley"]
        
        for i in 0..<count {
            // Generate random offset from center (within ~50 miles)
            let latOffset = Double.random(in: -0.5...0.5)
            let lngOffset = Double.random(in: -0.5...0.5)
            
            let randomLat = centerLat + latOffset
            let randomLng = centerLng + lngOffset
            
            // Generate random name
            let namePrefix = locationPrefixes.randomElement() ?? "New"
            let nameSuffix = locationNames.randomElement() ?? "Area"
            let randomName = "\(namePrefix) \(nameSuffix) \(i+1)"
            
            // Get random sentiment and emoji
            let index = Int.random(in: 0..<sentiments.count)
            let randomSentiment = sentiments[index]
            let emoji = emojis[min(index, emojis.count - 1)]
            
            let emotion = MapCityEmotion(
                cityName: randomName,
                coordinate: CLLocationCoordinate2D(latitude: randomLat, longitude: randomLng),
                emoji: emoji,
                sentiment: randomSentiment
            )
            
            randomEmotions.append(emotion)
        }
        
        return randomEmotions
    }
}
