//
//  LoadingView.swift
//  APIPOKEMON
//
//  Estado de carga compartido por la lista y el detalle.
//  Clean Code — DRY: un solo ProgressView, no uno copiado en cada pantalla.
//

import SwiftUI

struct LoadingView: View {
    var title: String = "Cargando Pokémon…"

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
