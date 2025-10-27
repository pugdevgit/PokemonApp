import SwiftUI
import Kingfisher

struct PokemonListView: View {
    @EnvironmentObject var viewModel: PokemonViewModel
    let isShowingFavorites: Bool
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.filteredPokemons(showFavorites: isShowingFavorites)) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                        PokemonRow(pokemon: pokemon)
                            .onAppear {
                                if !isShowingFavorites {
                                    viewModel.loadMoreIfNeeded(currentPokemon: pokemon)
                                }
                            }
                    }
                }
                
                if viewModel.isLoadingMore && !isShowingFavorites {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                viewModel.loadPokemons(refresh: true)
            }
            
            if viewModel.filteredPokemons(showFavorites: isShowingFavorites).isEmpty {
                emptyStateView
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Unknown error"),
                primaryButton: .default(Text("Retry")) {
                    viewModel.loadPokemons(refresh: true)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: isShowingFavorites ? "star.slash" : "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(isShowingFavorites ? "No Favorites Yet" : "No Pokémon Available")
                .font(.title2)
                .fontWeight(.medium)
            
            if isShowingFavorites {
                Text("Add Pokémon to your favorites by tapping the star icon.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Button(action: {
                    viewModel.loadPokemons(refresh: true)
                }) {
                    Text("Try Again")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

struct PokemonRow: View {
    let pokemon: PokemonListItem
    @EnvironmentObject var viewModel: PokemonViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            KFImage(pokemon.imageUrl)
                .placeholder {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
            Text(pokemon.name.capitalized)
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                viewModel.toggleFavorite(for: pokemon.id)
            }) {
                Image(systemName: viewModel.isFavorite(pokemonId: pokemon.id) ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite(pokemonId: pokemon.id) ? .yellow : .gray)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}
