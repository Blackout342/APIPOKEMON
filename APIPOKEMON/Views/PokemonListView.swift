//
//  PokemonListView.swift
//  APIPOKEMON

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
                .navigationTitle("Pokedex")
                .navigationDestination(for: PokemonSummary.self) { summary in
                    PokemonDetailView(summary: summary)
                }
                .searchable(text: $searchText, prompt: "Search by name or number")
        }
        .task {
            guard !viewModel.hasLoaded else { return }
            await viewModel.load()
        }
        .alert(
            "Could not refresh",
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
                Label("No results", systemImage: "magnifyingglass")
            } description: {
                Text("No Pokemon match \"\(searchText)\".")
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
// esta es la funcion que filtra los pokemons por nombre, numero o id
// se usa en la lista de pokemons
// se usa en la lista de pokemons
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
