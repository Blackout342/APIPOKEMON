# APIPOKEMON

A SwiftUI Pokedex. It shows the first generation of Pokemon in a list and, when a row is tapped, opens the entry with image, description, types, measurements, and stats.

## What the app does

- Requests the Pokemon list and shows it in a `List` inside a `NavigationStack`.
- Tapping a row opens a detail with the official artwork, the Pokedex text, types, height, weight, abilities, and stats.
- Shows a `ProgressView` while data is loading.
- If there is no connection, shows "No connection. Please try again." and a button to try again.
- If the API responds with an error, shows the status code. A failure does not close the app.
- Search by name or number, and refresh the list by pulling down.
