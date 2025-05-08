import SwiftUI

struct MainAppView: View {
    @State private var selectedTab: Int = 0
    @State private var showEmotionPicker: Bool = false
    @State private var selectedEmotion: String? = nil

    // ✅ Use EnvironmentObject, don't declare AppState here
    @EnvironmentObject var appState: AppState
    @StateObject private var emotionDatabase: EmotionDatabase = EmotionDatabase()

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeScreen()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                MapScreen()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(1)

                EmptyView()
                    .tabItem {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .tag(2)

                ContactsScreen()
                    .tabItem {
                        Label("Contacts", systemImage: "person.2.fill")
                    }
                    .tag(3)

                SettingsScreen()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(4)
            }
            .onChange(of: selectedTab) { newValue in
                if newValue == 2 {
                    showEmotionPicker = true
                    selectedTab = 0
                }
            }

            if showEmotionPicker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showEmotionPicker = false
                    }

                EmotionPickerView(
                    isShowing: $showEmotionPicker,
                    selectedEmotion: $selectedEmotion,
                    onSubmit: saveEmotionToDatabase
                )
                .transition(.move(edge: .bottom))
            }
        }
        .environmentObject(emotionDatabase)
    }

    func saveEmotionToDatabase() {
        guard let emotion = selectedEmotion else { return }
        let locationName = appState.getCurrentCityName()
        let timestamp = Date()

        emotionDatabase.saveEmotion(
            emotion: emotion,
            location: locationName,
            timestamp: timestamp
        )

        selectedEmotion = nil
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .environmentObject(AppState.shared) // ✅ provide AppState for previews
            .environmentObject(EmotionDatabase())
    }
}
