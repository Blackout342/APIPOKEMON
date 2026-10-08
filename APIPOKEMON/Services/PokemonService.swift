//
//  PokemonService.swift
//  APIPOKEMON
//
//  Único lugar que habla con la red.
//
//  Endpoints (PokéAPI, https://pokeapi.co):
//  - Lista:       GET https://pokeapi.co/api/v2/pokemon?limit=151
//  - Detalle:     GET https://pokeapi.co/api/v2/pokemon/{id}
//  - Descripción: GET https://pokeapi.co/api/v2/pokemon-species/{id}
//
//  Clean Code — DRY: todas las llamadas pasan por request(_:), que revisa
//  el estado HTTP y convierte la falta de red en PokemonAPIError.offline.
//  Clean Code — funciones pequeñas: cada método hace un solo paso.
//

import Foundation

/// Contrato del servicio. El ViewModel depende de esto, no de URLSession.
/// El servicio no está en el actor principal: solo descarga datos.
/// El ViewModel, que sí actualiza la pantalla, vive en MainActor.
nonisolated protocol PokemonFetching: Sendable {
    func fetchList(limit: Int) async throws -> [PokemonSummary]
    func fetchDetail(id: Int) async throws -> PokemonDetail
}

nonisolated struct PokemonService: PokemonFetching {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Un decoder nuevo por llamada. Así el servicio puede cruzar actores sin estado compartido.
    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        // base_experience llega como baseExperience sin CodingKeys manuales.
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func fetchList(limit: Int) async throws -> [PokemonSummary] {
        let url = try makeURL(
            path: "pokemon",
            query: [URLQueryItem(name: "limit", value: String(limit))]
        )
        let data = try await request(url)
        let page = try decode(PokemonListDTO.self, from: data, decoder: makeDecoder())

        // Si una URL no trae id, se omite. No se fuerza un unwrap.
        return page.results.compactMap { entry in
            guard let id = entry.pokemonID else { return nil }
            return PokemonSummary(id: id, name: entry.name)
        }
        .sorted { $0.id < $1.id }
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        let pokemonURL = try makeURL(path: "pokemon/\(id)")
        let speciesURL = try makeURL(path: "pokemon-species/\(id)")

        // El detalle es obligatorio. La descripción, si falla, no bloquea la ficha.
        async let pokemonData = request(pokemonURL)
        async let speciesData = optionalRequest(speciesURL)

        let decoder = makeDecoder()
        let pokemon = try decode(PokemonDTO.self, from: try await pokemonData, decoder: decoder)
        let species = await speciesData.flatMap { data in
            try? decode(SpeciesDTO.self, from: data, decoder: decoder)
        }
        return pokemon.makeDetail(species: species)
    }

    /// GET con código HTTP y errores de red ya traducidos a un mensaje.
    private func request(_ url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse else {
                throw PokemonAPIError.unknown
            }
            guard (200 ... 299).contains(http.statusCode) else {
                throw PokemonAPIError.badStatus(http.statusCode)
            }
            return data
        } catch let error as PokemonAPIError {
            throw error
        } catch let error as URLError {
            throw map(error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw PokemonAPIError.unknown
        }
    }

    /// Misma descarga, pero un fallo deja la descripción vacía en lugar de tumbar el detalle.
    private func optionalRequest(_ url: URL) async -> Data? {
        try? await request(url)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data, decoder: JSONDecoder) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw PokemonAPIError.decoding
        }
    }

    private func makeURL(path: String, query: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(string: "https://pokeapi.co/api/v2/\(path)") else {
            throw PokemonAPIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else {
            throw PokemonAPIError.invalidURL
        }
        return url
    }

    /// Sin red no es un error genérico: la vista muestra el mensaje de conexión.
    private func map(_ error: URLError) -> Error {
        switch error.code {
        case .cancelled:
            return CancellationError()
        case .notConnectedToInternet,
             .networkConnectionLost,
             .dataNotAllowed,
             .internationalRoamingOff,
             .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed,
             .timedOut:
            return PokemonAPIError.offline
        default:
            return PokemonAPIError.unknown
        }
    }
}

// MARK: - JSON de la PokéAPI
// Estos tipos viven aquí a propósito: la vista nunca ve la forma del JSON.
// Clean Code — responsabilidad única del servicio: mapear la respuesta.

nonisolated private struct PokemonListDTO: Decodable {
    let results: [PokemonEntryDTO]
}

nonisolated private struct PokemonEntryDTO: Decodable {
    let name: String
    let url: String

    /// "https://pokeapi.co/api/v2/pokemon/25/" -> 25
    var pokemonID: Int? {
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return Int(trimmed.split(separator: "/").last ?? "")
    }
}

nonisolated private struct PokemonDTO: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let baseExperience: Int?
    let sprites: SpriteDTO
    let types: [TypeSlotDTO]
    let abilities: [AbilitySlotDTO]
    let stats: [StatSlotDTO]

    func makeDetail(species: SpeciesDTO?) -> PokemonDetail {
        PokemonDetail(
            id: id,
            name: name,
            heightDecimeters: height,
            weightHectograms: weight,
            baseExperience: baseExperience,
            imageURL: sprites.artworkURL,
            types: types.map(\.type.name),
            abilities: abilities.map {
                PokemonAbility(name: $0.ability.name, isHidden: $0.isHidden)
            },
            stats: stats.map {
                PokemonStat(name: $0.stat.name, value: $0.baseStat)
            },
            genus: species?.preferredGenus ?? "Pokemon",
            about: species?.preferredAbout ?? "No description available."
        )
    }
}

nonisolated private struct SpriteDTO: Decodable {
    let artworkURL: URL?

    private enum CodingKeys: String, CodingKey {
        case other
    }

    private enum OtherKeys: String, CodingKey {
        // El guion no lo convierte convertFromSnakeCase.
        case officialArtwork = "official-artwork"
    }

    private enum ArtworkKeys: String, CodingKey {
        // front_default ya llega como frontDefault por la estrategia del decoder.
        case frontDefault
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Algunos recursos no traen "other"; la ficha sigue siendo válida.
        guard container.contains(.other) else {
            artworkURL = nil
            return
        }
        let other = try container.nestedContainer(keyedBy: OtherKeys.self, forKey: .other)
        guard other.contains(.officialArtwork) else {
            artworkURL = nil
            return
        }
        let artwork = try other.nestedContainer(keyedBy: ArtworkKeys.self, forKey: .officialArtwork)
        artworkURL = try artwork.decodeIfPresent(URL.self, forKey: .frontDefault)
    }
}

nonisolated private struct TypeSlotDTO: Decodable {
    let type: NamedDTO
}

nonisolated private struct AbilitySlotDTO: Decodable {
    let isHidden: Bool
    let ability: NamedDTO
}

nonisolated private struct StatSlotDTO: Decodable {
    let baseStat: Int
    let stat: NamedDTO
}

nonisolated private struct NamedDTO: Decodable {
    let name: String
}

nonisolated private struct SpeciesDTO: Decodable {
    let genera: [GenusDTO]
    let flavorTextEntries: [FlavorDTO]

    var preferredGenus: String? {
        Self.preferredText(genera.map { ($0.language.name, $0.genus) })
    }

    var preferredAbout: String? {
        let pairs = flavorTextEntries.map { ($0.language.name, $0.flavorText) }
        guard let text = Self.preferredText(pairs) else { return nil }
        return Self.clean(text)
    }

    /// Texto en inglés de la API. No se traduce.
    private static func preferredText(_ pairs: [(String, String)]) -> String? {
        pairs.first { $0.0 == "en" }?.1
    }

    /// Las fichas antiguas traen saltos de línea y un salto de página (\u{000c}).
    private static func clean(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\u{000c}", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

nonisolated private struct GenusDTO: Decodable {
    let genus: String
    let language: NamedDTO
}

nonisolated private struct FlavorDTO: Decodable {
    let flavorText: String
    let language: NamedDTO
}

#if DEBUG
/// Datos fijos para la vista previa de Xcode. No se usa en la app publicada.
nonisolated struct PreviewPokemonService: PokemonFetching {
    func fetchList(limit: Int) async throws -> [PokemonSummary] {
        let samples = [
            PokemonSummary(id: 1, name: "bulbasaur"),
            PokemonSummary(id: 4, name: "charmander"),
            PokemonSummary(id: 7, name: "squirtle")
        ]
        return Array(samples.prefix(max(limit, 0)))
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        return PokemonDetail(
            id: id,
            name: "bulbasaur",
            heightDecimeters: 7,
            weightHectograms: 69,
            baseExperience: 64,
            imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"),
            types: ["grass", "poison"],
            abilities: [
                PokemonAbility(name: "overgrow", isHidden: false),
                PokemonAbility(name: "chlorophyll", isHidden: true)
            ],
            stats: [
                PokemonStat(name: "hp", value: 45),
                PokemonStat(name: "attack", value: 49),
                PokemonStat(name: "defense", value: 49),
                PokemonStat(name: "special-attack", value: 65),
                PokemonStat(name: "special-defense", value: 65),
                PokemonStat(name: "speed", value: 45)
            ],
            genus: "Seed Pokemon",
            about: "A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokemon."
        )
    }
}
#endif
