//
//  PokemonListView.swift
//  APIPOKEMON
//
//  Nivel 1: lista dentro de NavigationStack.
//  MVVM: la vista observa PokemonListViewModel y no llama a URLSession.
//  Clean Code — el filtro de búsqueda es estado de esta pantalla,
//  porque no cambia lo que llegó de la API.
//

import SwiftUI

struct PokemonListView: View {
    @State private var viewModel: PokemonListViewModel
    @State private var searchText = ""

    init(viewModel: PokemonListViewModel = PokemonListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Pokédex")
                .navigationDestination(for: PokemonSummary.self) { summary in
                    // Nivel 2: el toque de la fila abre el detalle de ese Pokémon.
                    PokemonDetailView(summary: summary)
                }
                .searchable(text: $searchText, prompt: "Buscar por nombre o número")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await viewModel.load() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(viewModel.isLoading)
                        .accessibilityLabel("Actualizar")
                    }
                }
        }
        .task {
            // Solo la primera vez. Un reintento posterior lo dispara el botón.
            guard !viewModel.hasLoaded else { return }
            await viewModel.load()
        }
        .alert(
            "No se pudo actualizar",
            isPresented: showRefreshError
        ) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        // El orden importa: durante un reintento isLoading vuelve a true
        // y la lista sigue vacía. Ahí se muestra la carga, no "sin resultados".
        if viewModel.isLoading && viewModel.pokemons.isEmpty {
            LoadingView()
        } else if let message = viewModel.errorMessage, viewModel.pokemons.isEmpty {
            ErrorStateView(message: message, isOffline: viewModel.isOffline) {
                Task { await viewModel.load() }
            }
        } else if !viewModel.hasLoaded {
            LoadingView()
        } else if visiblePokemons.isEmpty {
            ContentUnavailableView {
                Label("Sin resultados", systemImage: "magnifyingglass")
            } description: {
                Text("No hay Pokémon que coincidan con “\(searchText)”.")
            }
        } else {
            List(visiblePokemons) { pokemon in
                NavigationLink(value: pokemon) {
                    PokemonRowView(pokemon: pokemon)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.load()
            }
        }
    }

    /// Si el refresco falla y la lista ya tiene datos, el error va en alerta.
    /// Así no se esconde lo que el usuario ya podía ver.
    private var showRefreshError: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil && !viewModel.pokemons.isEmpty },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearError()
                }
            }
        )
    }

    private var visiblePokemons: [PokemonSummary] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return viewModel.pokemons }
        return viewModel.pokemons.filter { pokemon in
            pokemon.displayName.localizedCaseInsensitiveContains(query)
                || pokemon.numberText.localizedCaseInsensitiveContains(query)
                || String(pokemon.id).contains(query)
        }
    }
}

#Preview {
    PokemonListView(viewModel: PokemonListViewModel(service: PreviewPokemonService()))
}
