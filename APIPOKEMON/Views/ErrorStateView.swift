//
//  ErrorStateView.swift
//  APIPOKEMON
//
//  Pantalla de fallo con reintento. Cubre red caída y error de la API.
//  Clean Code — responsabilidad única: mostrar el mensaje y el botón.
//

import SwiftUI

struct ErrorStateView: View {
    let message: String
    let isOffline: Bool
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isOffline ? "wifi.slash" : "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Button("Reintentar", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
