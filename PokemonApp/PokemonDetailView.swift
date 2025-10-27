import SwiftUI
import Kingfisher
import Combine

struct PokemonDetailView: View {
    let pokemon: PokemonListItem
    @EnvironmentObject var viewModel: PokemonViewModel
    @State private var pokemonDetail: PokemonDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9),
                    colorScheme == .dark ? Color(white: 0.1) : Color(white: 1.0)
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Pokemon Image
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
                            .frame(width: 200, height: 200)
                        
                        KFImage(pokemon.imageUrl)
                            .placeholder {
                                ProgressView()
                            }
                            .fade(duration: 0.25)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 180, height: 180)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 25) {
                        // Pokemon Name
                        Text(pokemon.name.capitalized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        // Favorite Button
                        Button(action: {
                            viewModel.toggleFavorite(for: pokemon.id)
                        }) {
                            Label(
                                viewModel.isFavorite(pokemonId: pokemon.id) ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: viewModel.isFavorite(pokemonId: pokemon.id) ? "star.fill" : "star"
                            )
                            .font(.headline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 25)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .background(viewModel.isFavorite(pokemonId: pokemon.id) ? Color.yellow : Color.blue)
                            .cornerRadius(10)
                        }
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                        } else if let detail = pokemonDetail {
                            // Pokemon Stats
                            statsView(for: detail)
                        } else if errorMessage != nil {
                            // Error View
                            errorView
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding()
                }
            }
        }
        .navigationTitle("Pokémon Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPokemonDetail()
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "Unknown error"),
                primaryButton: .default(Text("Retry")) {
                    loadPokemonDetail()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func loadPokemonDetail() {
        isLoading = true
        errorMessage = nil
        
        viewModel.fetchPokemonDetail(for: pokemon.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError {
                        errorMessage = networkError.errorDescription
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    showError = true
                }
            } receiveValue: { detail in
                self.pokemonDetail = detail
            }
            .store(in: &AnyCancellable.storage)
    }
    
    private func statsView(for detail: PokemonDetail) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            StatRow(title: "Experience", value: "\(detail.baseExperience) XP", systemImage: "sparkles")
            StatRow(title: "Height", value: "\(Float(detail.height) / 10.0) m", systemImage: "ruler")
            StatRow(title: "Weight", value: "\(Float(detail.weight) / 10.0) kg", systemImage: "scalemass")
        }
        .padding()
        .background(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.97))
        .cornerRadius(15)
    }
    
    private var errorView: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Failed to load details")
                .font(.headline)
            
            Button("Retry") {
                loadPokemonDetail()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let systemImage: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: systemImage)
                .font(.system(size: 22))
                .frame(width: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            
            Spacer()
        }
    }
}

// Helper extension for AnyCancellable storage
extension AnyCancellable {
    private static var cancellables = Set<AnyCancellable>()
    
    static var storage: Set<AnyCancellable> {
        get { cancellables }
        set { cancellables = newValue }
    }
}
