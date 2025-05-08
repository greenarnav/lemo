import SwiftUI

// Local type to avoid namespace issues
fileprivate struct LocalCitySentiment: Identifiable, Hashable {
    let id = UUID()
    let city: String
    let emoji: String
    let label: String
    let intensity: Double
    var whatPeopleThinking: [String] = []
    var whatPeopleCare: [String] = []
    
    static func == (lhs: LocalCitySentiment, rhs: LocalCitySentiment) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Converter from the global CitySentiment to local version
    init(from citySentiment: CitySentiment) {
        self.city = citySentiment.city
        self.emoji = citySentiment.emoji
        self.label = citySentiment.label
        self.intensity = citySentiment.intensity
        self.whatPeopleThinking = citySentiment.whatPeopleThinking
        self.whatPeopleCare = citySentiment.whatPeopleCare
    }
}

struct CityDetailScreen: View {
    // Use the original type in the public interface
    let city: CitySentiment
    
    // Private property to convert to our local type
    private var localCity: LocalCitySentiment {
        LocalCitySentiment(from: city)
    }
    
    var body: some View {
        // Use the same background gradient as the HomeScreen for consistency
        ZStack {
            // Dynamic background gradient based on city emotion
            LinearGradient(
                gradient: Gradient(colors: EmotionTheme.gradientColors(for: localCity.label)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(localCity.city)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(EmotionTheme.textColor(for: localCity.label))
                    
                    Text("What are people thinking")
                        .font(.title3)
                        .foregroundColor(EmotionTheme.textColor(for: localCity.label))
                        .padding(.top)
                    
                    ForEach(localCity.whatPeopleThinking, id: \.self) { idea in
                        Text(idea)
                            .padding()
                            .background(EmotionTheme.cardColor(for: localCity.label))
                            .cornerRadius(10)
                    }
                    
                    Text("What people care about")
                        .font(.title3)
                        .foregroundColor(EmotionTheme.textColor(for: localCity.label))
                    
                    HStack {
                        ForEach(localCity.whatPeopleCare, id: \.self) { cat in
                            Text(cat)
                                .padding(8)
                                .background(EmotionTheme.cardColor(for: localCity.label))
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(localCity.city)
    }
}
