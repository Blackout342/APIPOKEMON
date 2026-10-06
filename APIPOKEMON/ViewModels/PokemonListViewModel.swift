//
//  PokemonListViewModel.swift
//  APIPOKEMON
//
//  MVVM: esta clase es el ViewModel de la lista.
//  Pide datos al servicio, guarda el estado (carga, error, resultados)
//  y no construye vistas.
//  Clean Code — funciones pequeñas: load() solo orquesta el caso de uso.
//

import Foundation
import Observation

@MainActor
@Observable
final class PokemonListViewModel {
    private(set) var pokemons: [PokemonSummary] = []
    private(set) var isLoading = false
    /// Evita mostrar "sin resultados" en el primer frame, antes de que arranque la red.
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private(set) var isOffline = false

    private let service: PokemonFetching

    /// nonisolated: SwiftUI crea la vista fuera del actor principal.
    /// Aquí solo se guarda el servicio; la red sigue en load().
    nonisolated init(service: PokemonFetching = PokemonService()) {
        self.service = service
    }

    /// Primera carga y actualización. Un fallo llena el mensaje; no relanza.
    func load() async {
        isLoading = true
        errorMessage = nil
        isOffline = false
        defer { isLoading = false }

        do {
            // Primera generación: 151 fichas, suficiente para la lista.
            pokemons = try await service.fetchList(limit: 151)
            hasLoaded = true
        } catch is CancellationError {
            // La pantalla se fue o SwiftUI canceló la tarea. No es un error visible.
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
