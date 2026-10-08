//
//  PokemonDetail.swift
//  APIPOKEMON
//
//  Modelo de pantalla del detalle. La vista solo lee textos ya preparados.
//  Clean Code — nombres con intención y sin lógica de red en el modelo.
//

import Foundation

nonisolated struct PokemonAbility: Identifiable, Hashable {
    let name: String
    let isHidden: Bool

    var id: String { "\(name)-\(isHidden)" }

    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

nonisolated struct PokemonStat: Identifiable, Hashable {
    let name: String
    let value: Int

    var id: String { name }
}

/// Detalle listo para pintar: imagen, descripción, tipos y estadísticas.
nonisolated struct PokemonDetail: Identifiable, Hashable {
    let id: Int
    let name: String
    /// Altura de la API, en decímetros.
    let heightDecimeters: Int
    /// Peso de la API, en hectogramos.
    let weightHectograms: Int
    let baseExperience: Int?
    let imageURL: URL?
    let types: [String]
    let abilities: [PokemonAbility]
    let stats: [PokemonStat]
    let genus: String
    /// Texto de la Pokédex en inglés (endpoint de especie). No se traduce.
    let about: String

    var numberText: String {
        String(format: "#%03d", id)
    }

    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }

    /// La API mide en decímetros; en pantalla se ve en metros.
    var heightText: String {
        String(format: "%.1f m", Double(heightDecimeters) / 10)
    }

    /// La API mide en hectogramos; en pantalla se ve en kilogramos.
    var weightText: String {
        String(format: "%.1f kg", Double(weightHectograms) / 10)
    }

    var experienceText: String {
        if let baseExperience {
            return "\(baseExperience)"
        }
        return "—"
    }
}
