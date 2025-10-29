# PokemonApp (SwiftUI)

A simple SwiftUI Pokédex that fetches data from PokeAPI, supports infinite scrolling, pull-to-refresh, detail screens, offline cache for list and details, and favorites persisted with UserDefaults.

## Features
- **Pokémon list** with official artwork
- **Infinite scroll** with prefetching near the end
- **Pull to refresh**
- **Detail screen** with base experience, height, weight and artwork
- **Favorites**: mark/unmark, view favorites tab, clear all with confirmation
- **Offline support**: cached list and details, graceful errors when offline
- **Error handling** with retry

## Tech stack
- **SwiftUI** for UI
- **Combine** for async networking pipelines
- **URLSession** for HTTP requests to PokeAPI
- **Kingfisher** for remote image loading and caching
- **Network framework (NWPathMonitor)** for connectivity awareness
- **UserDefaults** as a simple cache/persistence layer
- **Architecture**: MVVM (views + `PokemonViewModel` + models)

## Requirements
- Xcode 15+
- iOS 16+
- Swift Package Manager (built into Xcode)

## Project structure
- `PokemonAppApp.swift` – App entry point, injects `PokemonViewModel`
- `ContentView.swift` – Segmented tabs: All / Favorites
- `PokemonListView.swift` – List, infinite scroll, pull-to-refresh, empty states, error alerts; uses `Kingfisher`
- `PokemonDetailView.swift` – Details (opened from the list)
- `PokemonViewModel.swift` – Pagination, networking, caching, favorites, error handling
- `PokemonModels.swift` – Codable models, cache helper, error definitions
- `Assets.xcassets` – Assets

## Data source
- PokeAPI: https://pokeapi.co/
  - List: `GET /api/v2/pokemon?limit={limit}&offset={offset}`
  - Details: `GET /api/v2/pokemon/{id}`
  - Artwork: GitHub sprites repo (official-artwork)

## Setup and run
1. Open `PokemonApp.xcodeproj` in Xcode.
2. Ensure the Kingfisher package is added via SPM if Xcode prompts to resolve packages:
   - File → Add Packages… → Search for `https://github.com/onevcat/Kingfisher`
   - Add to the project target.
3. Select an iOS simulator (iOS 16+).
4. Build and run (Cmd+R).

## Notes on caching and offline
- List cache: stored as JSON in `UserDefaults` and used when offline.
- Details cache: per Pokémon detail JSON cached on first successful load.
- Favorites: stored as a `Set<String>` of Pokémon IDs in `UserDefaults` with ability to clear all.

