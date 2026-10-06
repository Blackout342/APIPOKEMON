//
//  PokemonRowView.swift
//  APIPOKEMON
//
//  Una fila de la lista: número, nombre e imagen.
//  Clean Code — vista pequeña. No navega ni descarga la ficha completa.
//

import SwiftUI

struct PokemonRowView: View {
    let pokemon: PokemonSummary

    var body: some View {
        HStack(spacing: 16) {
            PokemonArtwork(url: artworkURL, side: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.numberText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(pokemon.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pokemon.displayName), \(pokemon.numberText)")
    }

    /// Misma ilustración oficial que devuelve el detalle, armada con el id de la lista
    /// para no pedir 151 fichas solo por pintar las filas.
    private var artworkURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.id).png")
    }
}

/// Imagen de red con carga y un respaldo si el archivo no llega.
struct PokemonArtwork: View {
    let url: URL?
    var side: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            @unknown default:
                Color.clear
            }
        }
        .frame(width: side, height: side)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }
}
