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
            // Requisito: si no hay red, un mensaje claro y reintento.
            return "Sin conexión. Inténtalo de nuevo."
        case .invalidURL:
            return "No se pudo crear la solicitud."
        case .badStatus(let code):
            // Requisito: si la API falla, mostrar el código de estado.
            return "La solicitud a la API falló (código \(code))."
        case .decoding:
            return "No se pudo leer la información recibida."
        case .unknown:
            return "Algo salió mal. Inténtalo de nuevo."
        }
    }
}
