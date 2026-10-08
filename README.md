# APIPOKEMON

Pokédex en SwiftUI. Muestra la primera generación de Pokémon en una lista y, al tocar una fila, abre la ficha con imagen, descripción, tipos, medidas y estadísticas.

## Qué hace la app

- Pide la lista de Pokémon y la muestra en un `List` dentro de un `NavigationStack`.
- Al tocar una fila abre un detalle con la ilustración oficial, el texto de la Pokédex, los tipos, altura, peso, habilidades y estadísticas.
- Mientras llegan los datos muestra un `ProgressView`.
- Si no hay conexión, muestra «Sin conexión. Inténtalo de nuevo.» y un botón para reintentar.
- Si la API responde con error, muestra el código de estado. Un fallo no cierra la app.
- Se puede buscar por nombre o número y actualizar la lista deslizando hacia abajo.
