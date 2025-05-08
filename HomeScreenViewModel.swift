import SwiftUI
import Combine

@MainActor
final class HomeScreenViewModel: ObservableObject {
    // MARK: - Published state
    @Published var allCities: [CitySentiment] = []
    @Published var favorite: [CitySentiment] = []
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    @Published var lastUpdated = Date()
    
    // MARK: - Public API
    func fetch() {
        isLoading = true
        
        let _: Task<Void, Never> = Task {
            do {
                let url = URL(string: "https://mainoverallapi.vercel.app")!
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Direct dictionary approach instead of using ApiResponse struct
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: String],
                   let dataString = json["data"] {
                    try await parse(dataString)
                } else {
                    throw URLError(.cannotParseResponse)
                }
                
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func toggleFavorite(_ city: CitySentiment) {
        if let idx = favorite.firstIndex(where: { $0.city == city.city }) {
            favorite.remove(at: idx)
        } else {
            favorite.append(city)
        }
    }
    
    // MARK: - Helpers
    private func parse(_ jsonString: String) async throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw URLError(.badServerResponse)
        }
        
        let raw = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] ?? [:]
        
        allCities = raw.map { name, info in
            let sent = info["what_is_their_sentiment"] as? String ?? "neutral"
            let think = info["what_are_people_thinking"] as? [String] ?? []
            let care = info["what_do_people_care"] as? [String] ?? []
            
            return CitySentiment(
                city: name,
                emoji: getSentimentEmoji(sent),
                label: getSentimentLabel(sent),
                intensity: getSentimentIntensity(sent),
                whatPeopleThinking: think,
                whatPeopleCare: care
            )
        }
        .sorted { $0.city < $1.city }
        
        lastUpdated = .now
    }
}
