import SwiftUI
import Contacts

struct ContactsScreen: View {
    @StateObject private var viewModel = ContactsViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.5), .white.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("Contacts").font(.title2)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                
                if viewModel.loading {
                    Spacer()
                    ProgressView("Loading contacts...")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    Spacer()
                } else if viewModel.rows.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("No Contacts Found")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Import contacts to see their city mood")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.rows) { contact in
                                HStack(spacing: 16) {
                                    // Contact emoji
                                    Text(contact.emoji)
                                        .font(.system(size: 32))
                                        .frame(width: 60, height: 60)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Circle())
                                    
                                    // Contact info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(contact.name)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Text(contact.phone)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        HStack {
                                            Text(contact.city)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.white.opacity(0.15))
                                                .cornerRadius(8)
                                            
                                            Text(contact.mood)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(getSentimentColor(contact.mood).opacity(0.3))
                                                .cornerRadius(8)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}
