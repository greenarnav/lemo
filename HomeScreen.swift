// HomeScreen.swift
import SwiftUI

struct HomeScreen: View {
    // MARK: - State
    @StateObject private var vm = HomeScreenViewModel()
    @StateObject private var locationService = HomeScreenLocationService()
    @StateObject private var forecastService = HomeForecastService()
    @State private var searchText = ""
    @State private var currentPage = 0
    
    private let perPage = 3
    
    // MARK: - Derived data
    private var filtered: [CitySentiment] {
        searchText.isEmpty
        ? vm.allCities
        : vm.allCities.filter { $0.city.lowercased().contains(searchText.lowercased()) }
    }
    
    private var page: [CitySentiment] {
        let start = currentPage * perPage
        let end = min(start + perPage, filtered.count)
        return start < filtered.count ? Array(filtered[start..<end]) : []
    }
    
    private var totalPages: Int {
        max(1, (filtered.count + perPage - 1) / perPage)
    }
    
    // MARK: - View body
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.5), .white.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                if vm.isLoading {
                    ProgressView("Loading…")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                } else if let msg = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load")
                        Text(msg).font(.caption2)
                        Button("Retry") { vm.fetch() }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    mainContentView
                }
            }
            .navigationBarHidden(true)
            .task {
                vm.fetch()
                locationService.requestLocation()
            }
            .refreshable {
                vm.fetch()
                locationService.requestLocation()
            }
        }
    }
    
    // MARK: - Main content stack
    private var mainContentView: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "location.fill")
                Text("Cities Mood").font(.title2)
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            
            // Current location
            if let cityMatch = vm.allCities.first(where: {
                $0.city.lowercased() == locationService.currentCity.lowercased()
            }) {
                HomeLocationCardView(city: cityMatch) {
                    // Navigate to city detail
                }
            } else if let first = vm.allCities.first {
                HomeLocationCardView(city: first) {
                    // Navigate to city detail
                }
            } else {
                Text("No city data available")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
            
            Text("Your location: \(locationService.currentCity)")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            // Forecast
            HomeForecastBarView(
                forecastService: forecastService,
                cityName: locationService.currentCity
            )
            
            // Search
            HomeSearchView(
                searchText: $searchText,
                onClear: {
                    searchText = ""
                    currentPage = 0
                }
            )
            
            // City cards
            HomeCityCardsView(
                cities: page,
                currentPage: currentPage,
                totalPages: totalPages,
                onPreviousPage: { currentPage = max(0, currentPage - 1) },
                onNextPage: { currentPage = min(totalPages - 1, currentPage + 1) },
                onToggleFavorite: { vm.toggleFavorite($0) },
                isFavorite: { city in vm.favorite.contains(where: { $0.city == city.city }) }
            )
            
            // Favorites
            if !vm.favorite.isEmpty {
                HomeFavoritesView(favorites: vm.favorite)
            }
            
            Spacer()
        }
        .padding(.top)
        .animation(.easeInOut, value: filtered.count)
    }
}
