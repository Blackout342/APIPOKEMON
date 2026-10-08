//
//  PokemonDetailViewModel.swift
//  APIPOKEMON
//
//  MVVM: ViewModel del detalle. La vista le dice cuándo cargar
//  y lee detail, isLoading y errorMessage.
//

import Foundation
import Observation

@MainActor
@Observable
final class PokemonDetailViewModel {
    let summary: PokemonSummary

    private(set) var detail: PokemonDetail?
    private(set) var isLoading = true
    private(set) var errorMessage: String?
    private(set) var isOffline = false

    private let service: PokemonFetching
    nonisolated init(summary: PokemonSummary, service: PokemonFetching = PokemonService()) {
        self.summary = summary
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        isOffline = false
        defer { isLoading = false }

        do {
            detail = try await service.fetchDetail(id: summary.id)
        } catch is CancellationError {
            // Cancelar al volver atrás no debe mostrar un error.
        } catch {
            let apiError = error as? PokemonAPIError
            isOffline = apiError == .offline
            errorMessage = apiError?.errorDescription ?? PokemonAPIError.unknown.errorDescription
        }
    }
}
