import Foundation
import Combine
import Network

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [PokemonListItem] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var favorites = Set<String>()
    @Published var showingDeleteConfirmation = false
    
    private var currentOffset = 0
    private let limit = 10
    private var canLoadMore = true
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NWPathMonitor()
    private var isConnected = true
    
    init() {
        setupNetworkMonitoring()
        loadFavorites()
        loadPokemons(refresh: true)
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if self?.isConnected == true && self?.pokemons.isEmpty == true {
                    self?.loadPokemons(refresh: true)
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
    
    func loadPokemons(refresh: Bool = false) {
        if refresh {
            isLoading = true
            currentOffset = 0
            canLoadMore = true
        } else if !canLoadMore || isLoadingMore {
            return
        } else {
            isLoadingMore = true
        }
        
        // Check for cached data on first load
        if refresh && !isConnected {
            if let cachedPokemons = PokemonCache.shared.getCachedPokemonList() {
                self.pokemons = cachedPokemons
                self.isLoading = false
                return
            }
        }
        
        // If offline and no cache, show error
        if !isConnected {
            handleError(NetworkError.noInternetConnection)
            isLoading = false
            isLoadingMore = false
            return
        }
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(currentOffset)") else {
            handleError(NetworkError.badURL)
            isLoading = false
            isLoadingMore = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                self.isLoading = false
                self.isLoadingMore = false
                
                if case .failure(let error) = completion {
                    self.handleError(error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                if refresh {
                    self.pokemons = response.results
                } else {
                    self.pokemons.append(contentsOf: response.results)
                }
                
                // Update cache on success
                PokemonCache.shared.cachePokemonList(pokemons: self.pokemons)
                
                self.currentOffset += self.limit
                self.canLoadMore = response.next != nil
            }
            .store(in: &cancellables)
    }
    
    func loadMoreIfNeeded(currentPokemon pokemon: PokemonListItem) {
        let thresholdIndex = pokemons.index(pokemons.endIndex, offsetBy: -3)
        if let itemIndex = pokemons.firstIndex(of: pokemon), itemIndex >= thresholdIndex {
            loadPokemons()
        }
    }
    
    func fetchPokemonDetail(for pokemonId: String) -> AnyPublisher<PokemonDetail, Error> {
        // Check cache first
        if let cachedDetail = PokemonCache.shared.getCachedPokemonDetail(pokemonId: pokemonId) {
            return Just(cachedDetail)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // If offline, return error
        if !isConnected {
            return Fail(error: NetworkError.noInternetConnection)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)") else {
            return Fail(error: NetworkError.badURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonDetail.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] detail in
                // Cache the result
                PokemonCache.shared.cachePokemonDetail(pokemonId: pokemonId, detail: detail)
            })
            .eraseToAnyPublisher()
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
    
    // MARK: - Favorites Management
    
    func toggleFavorite(for pokemonId: String) {
        if favorites.contains(pokemonId) {
            favorites.remove(pokemonId)
        } else {
            favorites.insert(pokemonId)
        }
        saveFavorites()
    }
    
    func isFavorite(pokemonId: String) -> Bool {
        favorites.contains(pokemonId)
    }
    
    private func loadFavorites() {
        favorites = PokemonCache.shared.getFavorites()
    }
    
    private func saveFavorites() {
        PokemonCache.shared.saveFavorites(favorites: favorites)
    }
    
    func removeAllFavorites() {
        favorites.removeAll()
        PokemonCache.shared.clearAllFavorites()
    }
    
    func filteredPokemons(showFavorites: Bool) -> [PokemonListItem] {
        if showFavorites {
            return pokemons.filter { favorites.contains($0.id) }
        } else {
            return pokemons
        }
    }
}
