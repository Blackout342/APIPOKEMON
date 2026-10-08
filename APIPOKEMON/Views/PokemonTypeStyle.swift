//
//  PokemonTypeStyle.swift
//  APIPOKEMON
//


import SwiftUI

enum PokemonTypeStyle {
    /// "fire" se muestra como "Fire". La palabra no se traduce.
    static func title(for type: String) -> String {
        type.replacingOccurrences(of: "-", with: " ").capitalized
    }

    static func color(for type: String) -> Color {
        switch type {
        case "fire": return Color(red: 0.93, green: 0.40, blue: 0.18)
        case "water": return Color(red: 0.27, green: 0.55, blue: 0.91)
        case "grass": return Color(red: 0.30, green: 0.69, blue: 0.31)
        case "electric": return Color(red: 0.94, green: 0.78, blue: 0.16)
        case "ice": return Color(red: 0.45, green: 0.78, blue: 0.78)
        case "fighting": return Color(red: 0.76, green: 0.25, blue: 0.29)
        case "poison": return Color(red: 0.62, green: 0.35, blue: 0.71)
        case "ground": return Color(red: 0.80, green: 0.65, blue: 0.35)
        case "flying": return Color(red: 0.56, green: 0.64, blue: 0.93)
        case "psychic": return Color(red: 0.93, green: 0.38, blue: 0.55)
        case "bug": return Color(red: 0.60, green: 0.70, blue: 0.20)
        case "rock": return Color(red: 0.70, green: 0.61, blue: 0.35)
        case "ghost": return Color(red: 0.45, green: 0.38, blue: 0.70)
        case "dragon": return Color(red: 0.42, green: 0.35, blue: 0.88)
        case "dark": return Color(red: 0.42, green: 0.34, blue: 0.29)
        case "steel": return Color(red: 0.55, green: 0.62, blue: 0.68)
        case "fairy": return Color(red: 0.91, green: 0.55, blue: 0.72)
        default: return Color(red: 0.56, green: 0.56, blue: 0.58)
        }
    }

    static func statTitle(_ name: String) -> String {
        if name == "hp" {
            return "HP"
        }
        return name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}
