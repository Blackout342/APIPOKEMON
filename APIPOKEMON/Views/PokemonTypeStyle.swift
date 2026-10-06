//
//  PokemonTypeStyle.swift
//  APIPOKEMON
//
//  Color y nombre en español de cada tipo. Solo presentación.
//  Clean Code — la vista del detalle no acumula este catálogo.
//

import SwiftUI

enum PokemonTypeStyle {
    static func title(for type: String) -> String {
        switch type {
        case "normal": return "Normal"
        case "fire": return "Fuego"
        case "water": return "Agua"
        case "grass": return "Planta"
        case "electric": return "Eléctrico"
        case "ice": return "Hielo"
        case "fighting": return "Lucha"
        case "poison": return "Veneno"
        case "ground": return "Tierra"
        case "flying": return "Volador"
        case "psychic": return "Psíquico"
        case "bug": return "Bicho"
        case "rock": return "Roca"
        case "ghost": return "Fantasma"
        case "dragon": return "Dragón"
        case "dark": return "Siniestro"
        case "steel": return "Acero"
        case "fairy": return "Hada"
        default:
            return type.replacingOccurrences(of: "-", with: " ").capitalized
        }
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
        switch name {
        case "hp": return "PS"
        case "attack": return "Ataque"
        case "defense": return "Defensa"
        case "special-attack": return "Ataque especial"
        case "special-defense": return "Defensa especial"
        case "speed": return "Velocidad"
        default:
            return name.replacingOccurrences(of: "-", with: " ").capitalized
        }
    }
}
