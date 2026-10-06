//
//  PokemonSummary.swift
//  APIPOKEMON
//
//  Dato mínimo de un Pokémon para la lista.
//  Clean Code — responsabilidad única: solo identidad y nombre, sin JSON.
//

import Foundation

/// Fila de la Pokédex. Llega desde GET /pokemon y se abre en el detalle.
nonisolated struct PokemonSummary: Identifiable, Hashable {
    let id: Int
    let name: String

    /// "#001". El número sale del id, no de un campo aparte de la API.
    var numberText: String {
        String(format: "#%03d", id)
    }

    /// "mr-mime" se muestra como "Mr Mime".
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}
