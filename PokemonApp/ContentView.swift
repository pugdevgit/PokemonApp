//
//  ContentView.swift
//  PokemonApp
//
//  Created by Oleg on 08.05.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var viewModel: PokemonViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Pokemon List", selection: $selectedTab) {
                    Text("All").tag(0)
                    Text("Favorites").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedTab == 0 {
                    PokemonListView(isShowingFavorites: false)
                } else {
                    PokemonListView(isShowingFavorites: true)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                if !viewModel.favorites.isEmpty {
                                    Button(action: {
                                        viewModel.showingDeleteConfirmation = true
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                        .alert("Remove All Favorites?", isPresented: $viewModel.showingDeleteConfirmation) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete All", role: .destructive) {
                                viewModel.removeAllFavorites()
                            }
                        } message: {
                            Text("This action cannot be undone.")
                        }
                }
            }
            .navigationTitle("Pokédex")
        }
    }
}

//#Preview {
//    ContentView()
//}
