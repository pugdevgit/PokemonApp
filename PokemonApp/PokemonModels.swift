import Foundation

// MARK: - Main Models
struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Codable, Identifiable, Equatable {
    let name: String
    let url: String
    
    var id: String {
        String(url.split(separator: "/").last ?? "")
    }
    
    var imageUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
    
    static func == (lhs: PokemonListItem, rhs: PokemonListItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct PokemonDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let baseExperience: Int
    let height: Int
    let weight: Int
    let sprites: Sprites
    
    enum CodingKeys: String, CodingKey {
        case id, name, height, weight
        case baseExperience = "base_experience"
        case sprites
    }
}

struct Sprites: Codable {
    let other: OtherSprites
}

struct OtherSprites: Codable {
    let officialArtwork: OfficialArtwork
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

// MARK: - Helper Models
enum NetworkError: Error, LocalizedError {
    case badURL
    case badResponse
    case decodingError
    case serverError(statusCode: Int)
    case noInternetConnection
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .badResponse:
            return "Bad response from server"
        case .decodingError:
            return "Failed to decode data"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .noInternetConnection:
            return "No internet connection"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Cache Models
class PokemonCache {
    static let shared = PokemonCache()
    
    private let defaults = UserDefaults.standard
    private let pokemonListKey = "cached_pokemon_list"
    private let pokemonDetailsKey = "cached_pokemon_details"
    private let favoritesKey = "favorite_pokemons"
    
    // Cache Pokemon List
    func cachePokemonList(pokemons: [PokemonListItem]) {
        if let encodedData = try? JSONEncoder().encode(pokemons) {
            defaults.set(encodedData, forKey: pokemonListKey)
        }
    }
    
    func getCachedPokemonList() -> [PokemonListItem]? {
        guard let data = defaults.data(forKey: pokemonListKey) else { return nil }
        return try? JSONDecoder().decode([PokemonListItem].self, from: data)
    }
    
    // Cache Pokemon Details
    func cachePokemonDetail(pokemonId: String, detail: PokemonDetail) {
        var details = getCachedPokemonDetails() ?? [:]
        if let encodedData = try? JSONEncoder().encode(detail) {
            details[pokemonId] = encodedData
            if let encodedDict = try? JSONEncoder().encode(details) {
                defaults.set(encodedDict, forKey: pokemonDetailsKey)
            }
        }
    }
    
    func getCachedPokemonDetail(pokemonId: String) -> PokemonDetail? {
        guard let details = getCachedPokemonDetails(),
              let data = details[pokemonId] else { return nil }
        return try? JSONDecoder().decode(PokemonDetail.self, from: data)
    }
    
    private func getCachedPokemonDetails() -> [String: Data]? {
        guard let data = defaults.data(forKey: pokemonDetailsKey) else { return nil }
        return try? JSONDecoder().decode([String: Data].self, from: data)
    }
    
    // Handle Favorites
    func saveFavorites(favorites: Set<String>) {
        defaults.set(Array(favorites), forKey: favoritesKey)
    }
    
    func getFavorites() -> Set<String> {
        let array = defaults.stringArray(forKey: favoritesKey) ?? []
        return Set(array)
    }
    
    func clearAllFavorites() {
        defaults.removeObject(forKey: favoritesKey)
    }
}
