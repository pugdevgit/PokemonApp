//
//  PokemonAppApp.swift
//  PokemonApp
//
//  Created by Oleg on 08.05.2025.
//

import SwiftUI

@main
struct PokemonAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PokemonViewModel())
        }
    }
}

