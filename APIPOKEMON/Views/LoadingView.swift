//
//  LoadingView.swift
//  APIPOKEMON

import SwiftUI

struct LoadingView: View {
    var title: String = "Loading Pokemon…"

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
