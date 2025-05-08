import SwiftUI

struct SettingsScreen: View {
    // Use EnvironmentObject with explicit type annotations
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var emotionDatabase: EmotionDatabase
    @State private var showClearDataAlert: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.5),
                    Color.white.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "gear")
                    Text("Settings").font(.title2)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // App info section
                        settingsSection(title: "App Info") {
                            settingsRow(icon: "info.circle", title: "Version", detail: "1.0.0")
                            settingsRow(icon: "envelope.fill", title: "Contact", detail: "support@moodgpt.com")
                        }
                        
                        // Location Section
                        settingsSection(title: "Location") {
                            settingsRow(icon: "location.fill", title: "Current Location", detail: appState.getFormattedLocation())
                            
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "gear")
                                        .foregroundColor(.white)
                                    Text("Location Settings")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Data Management Section
                        settingsSection(title: "Data Management") {
                            Button(action: {
                                showClearDataAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("Clear Emotion Data")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }
                            .alert(isPresented: $showClearDataAlert) {
                                Alert(
                                    title: Text("Clear Emotion Data"),
                                    message: Text("This will delete all your saved emotion records. This action cannot be undone."),
                                    primaryButton: .destructive(Text("Delete")) {
                                        emotionDatabase.userEmotions = []
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        
                        // About Section
                        settingsSection(title: "About") {
                            Text("MoodGPT helps you track your emotions and see how others around you are feeling. Explore the emotional climate of your city and connect with the collective sentiment of people around you.")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // Helper view builders with explicit function signatures
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            content()
        }
    }
    
    private func settingsRow(icon: String, title: String, detail: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(detail)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(10)
    }
}

// Add preview provider
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        // Force unwrap is safe here because we're setting up for preview
        SettingsScreen()
            .environmentObject(AppState.shared)
            .environmentObject(EmotionDatabase())
    }
}
