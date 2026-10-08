//
//  PokemonListViewModel.swift
//  APIPOKEMON
//
//  MVVM: esta clase es el ViewModel de la lista.
//  Pide datos al servicio, guarda el estado (carga, error, resultados)
//  y no construye vistas.


import Foundation
import Observation

@MainActor
@Observable
final class PokemonListViewModel {
    private(set) var pokemons: [PokemonSummary] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private(set) var isOffline = false

    private let service: PokemonFetching

    nonisolated init(service: PokemonFetching = PokemonService()) {
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        isOffline = false
        defer { isLoading = false }

        do {
            pokemons = try await service.fetchList(limit: 151)
            hasLoaded = true
        } catch is CancellationError {
        } catch {
            hasLoaded = true
            let apiError = error as? PokemonAPIError
            isOffline = apiError == .offline
            errorMessage = apiError?.errorDescription ?? PokemonAPIError.unknown.errorDescription
        }
    }

    func clearError() {
        errorMessage = nil
        isOffline = false
    }
}
