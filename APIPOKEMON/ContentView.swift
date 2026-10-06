//
//  ContentView.swift
//  APIPOKEMON
//
//  Punto de entrada visual. Delega en la lista para no mezclar responsabilidades.
//  MVVM: la vista raíz no tiene estado de red; eso vive en los ViewModels.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PokemonListView()
    }
}

#Preview {
    ContentView()
}
