import SwiftUI
import Contacts

// MARK: - Local SentimentService Implementation
fileprivate struct LocalSentimentService {
    static let shared = LocalSentimentService()
    
    func cityInfo(_ city: String) async throws -> (emoji: String, label: String) {
        // This is a placeholder implementation
        // You would replace this with your actual API call logic
        let sentiments = ["happy", "sad", "excited", "calm", "neutral"]
        let sentiment = sentiments.randomElement() ?? "neutral"
        
        return (emoji: getEmoji(for: sentiment), label: sentiment.capitalized)
    }
    
    // Helper function to get emoji for sentiment
    private func getEmoji(for sentiment: String) -> String {
        switch sentiment.lowercased() {
        case "happy", "joyful", "positive", "very positive":
            return "😊"
        case "sad", "negative", "very negative":
            return "😢"
        case "angry":
            return "😡"
        case "fear":
            return "😱"
        case "excited":
            return "😃"
        case "calm":
            return "😌"
        case "tired":
            return "😴"
        case "surprised":
            return "😲"
        case "confident":
            return "😎"
        case "neutral", "mixed":
            return "😐"
        default:
            return "🤔"
        }
    }
}

// MARK: - ContactsViewModel
@MainActor
final class ContactsViewModel: ObservableObject {
    struct Row: Identifiable {
        let id = UUID()
        let name: String
        let phone: String
        let city: String
        let emoji: String
        let mood: String
    }
    
    @Published var rows: [Row] = []
    @Published var loading = true
    
    // Public
    func load() {
        loading = true
        Task {
            await refresh()
            loading = false
        }
    }
    
    // Private
    private func refresh() async {
        // 1. Read contacts synchronously
        let store = CNContactStore()
        try? await store.requestAccess(for: .contacts)
        let req = CNContactFetchRequest(keysToFetch: [
            CNContactGivenNameKey as NSString,
            CNContactPhoneNumbersKey as NSString
        ])
        
        // temp holds (name, phone, areaCode)
        var temp: [(String,String,String)] = []
        try? store.enumerateContacts(with: req) { c, _ in
            guard let phone = c.phoneNumbers.first?.value.stringValue else { return }
            let area = String(phone.filter(\.isNumber).prefix(3))
            temp.append((c.givenName, phone, area))
        }
        
        // 2. Group by city + fetch sentiment in parallel
        var uniqueCities = Set<String>()
        rows.removeAll()
        
        await withTaskGroup(of: Row?.self) { group in
            for (name, phone, area) in temp {
                guard let loc = AreaCodeLookup.city(for: area) else { continue }
                if !uniqueCities.contains(loc.city) { uniqueCities.insert(loc.city) }
                
                group.addTask {
                    let sent = try? await LocalSentimentService.shared.cityInfo(loc.city)
                    return Row(
                        name: name,
                        phone: phone,
                        city: loc.city,
                        emoji: sent?.emoji ?? "🤔",
                        mood: sent?.label ?? "—"
                    )
                }
            }
            for await r in group { if let r = r { rows.append(r) } }
        }
        rows.sort { $0.name < $1.name }
    }
}
