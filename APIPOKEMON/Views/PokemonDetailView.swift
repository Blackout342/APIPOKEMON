//
//  PokemonDetailView.swift
//  APIPOKEMON
//
//  Nivel 2: ficha de un Pokémon.
//  MVVM: PokemonDetailViewModel carga el GET de detalle y el de especie.
//  Clean Code — el cuerpo elige el estado; el contenido vive en subvistas.
//

import SwiftUI

struct PokemonDetailView: View {
    @State private var viewModel: PokemonDetailViewModel

    init(summary: PokemonSummary, service: PokemonFetching = PokemonService()) {
        _viewModel = State(initialValue: PokemonDetailViewModel(summary: summary, service: service))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.detail == nil {
                LoadingView(title: "Cargando ficha…")
            } else if let message = viewModel.errorMessage, viewModel.detail == nil {
                ErrorStateView(message: message, isOffline: viewModel.isOffline) {
                    Task { await viewModel.load() }
                }
            } else if let detail = viewModel.detail {
                DetailContent(detail: detail)
            } else {
                ErrorStateView(
                    message: "No se encontró este Pokémon.",
                    isOffline: false
                ) {
                    Task { await viewModel.load() }
                }
            }
        }
        .navigationTitle(viewModel.summary.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.load()
        }
    }
}

/// Contenido de la ficha. Separado para que el estado de carga no se mezcle con el diseño.
private struct DetailContent: View {
    let detail: PokemonDetail

    private var accent: Color {
        PokemonTypeStyle.color(for: detail.types.first ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                aboutSection
                typesSection
                metrics
                abilitiesSection
                statsSection
            }
            .padding(20)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 240, height: 240)
                PokemonArtwork(url: detail.imageURL, side: 200)
            }
            .frame(maxWidth: .infinity)

            Text(detail.numberText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(detail.displayName)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(detail.genus)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Descripción")
            Text(detail.about)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var typesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Tipos")
            HStack(spacing: 8) {
                ForEach(detail.types, id: \.self) { type in
                    Text(PokemonTypeStyle.title(for: type))
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(PokemonTypeStyle.color(for: type), in: Capsule())
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var metrics: some View {
        HStack(spacing: 12) {
            MetricCard(title: "Altura", value: detail.heightText)
            MetricCard(title: "Peso", value: detail.weightText)
            MetricCard(title: "Experiencia", value: detail.experienceText)
        }
    }

    private var abilitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Habilidades")
            ForEach(detail.abilities) { ability in
                HStack {
                    Text(ability.displayName)
                        .font(.body)
                    Spacer()
                    if ability.isHidden {
                        Text("Oculta")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Estadísticas")
            ForEach(detail.stats) { stat in
                StatBar(name: stat.name, value: stat.value, tint: accent)
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
    }
}

private struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct StatBar: View {
    let name: String
    let value: Int
    let tint: Color

    /// 180 deja las barras legibles. El máximo teórico de la API es más alto.
    private var fraction: Double {
        min(Double(value) / 180, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(PokemonTypeStyle.statTitle(name))
                    .font(.subheadline)
                Spacer()
                Text("\(value)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.18))
                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: 8)
            .accessibilityLabel("\(PokemonTypeStyle.statTitle(name)) \(value)")
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView(
            summary: PokemonSummary(id: 1, name: "bulbasaur"),
            service: PreviewPokemonService()
        )
    }
}
