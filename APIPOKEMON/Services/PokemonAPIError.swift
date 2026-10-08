//
//  PokemonAPIError.swift
//  APIPOKEMON
//
//  Traduce fallos de red a un mensaje legible. La vista no inspecciona URLError.
//  Clean Code — responsabilidad única: representar el error, no descargarlo.
//

import Foundation

/// Errores que la interfaz puede mostrar sin tumbar la app.
nonisolated enum PokemonAPIError: LocalizedError, Equatable {
    case offline
    case invalidURL
    case badStatus(Int)
    case decoding
    case unknown

    var errorDescription: String? {
        switch self {
        case .offline:
            // Requisito: si no hay red, un mensaje claro.
            return "No connection. Please try again."
        case .invalidURL:
            return "The request could not be created."
        case .badStatus(let code):
            // Requisito: si la API falla, mostrar el código de estado.
            return "The API request failed (status \(code))."
        case .decoding:
            return "The data from the server could not be read."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
