# APIPOKEMON

Pokédex en SwiftUI. Muestra la primera generación de Pokémon en una lista y, al tocar una fila, abre la ficha con imagen, descripción, tipos, medidas y estadísticas.

## Qué hace la app

- Pide la lista de Pokémon y la muestra en un `List` dentro de un `NavigationStack`.
- Al tocar una fila abre un detalle con la ilustración oficial, el texto de la Pokédex, los tipos, altura, peso, habilidades y estadísticas.
- Mientras llegan los datos muestra un `ProgressView`.
- Si no hay conexión, muestra «Sin conexión. Inténtalo de nuevo.» y un botón para reintentar.
- Si la API responde con error, muestra el código de estado. Un fallo no cierra la app.
- Se puede buscar por nombre o número y actualizar la lista deslizando hacia abajo.

## API

Datos reales de [PokéAPI](https://pokeapi.co).

| Uso | Método | Endpoint |
| --- | --- | --- |
| Lista | GET | https://pokeapi.co/api/v2/pokemon?limit=151 |
| Detalle | GET | https://pokeapi.co/api/v2/pokemon/{id} |
| Descripción | GET | https://pokeapi.co/api/v2/pokemon-species/{id} |

La imagen del detalle sale del campo `sprites.other.official-artwork.front_default` de la ficha. En la lista se usa la misma ruta de ilustración con el id, para no descargar 151 fichas solo por pintar las filas.

## Cómo ejecutarla

- Xcode 27
- Destino: iOS 27.0 (iPhone o simulador)
- Sin paquetes externos. Solo SwiftUI y `URLSession`.

Pasos:

1. Abre `APIPOKEMON.xcodeproj` en Xcode.
2. Elige un simulador de iPhone como destino.
3. Pulsa Run (⌘R).
4. Espera la lista. Toca un Pokémon para ver el detalle.

La arquitectura es MVVM:

- `Models`: datos que ve la pantalla.
- `Services`: las peticiones GET y la traducción de errores.
- `ViewModels`: estado de carga, lista y ficha.
- `Views`: lista, fila, detalle, carga y error.
