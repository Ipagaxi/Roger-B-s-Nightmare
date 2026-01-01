# Developer Guide

## World Generation
The world dimensions are classified as follows:
  1. **Continent view**: The most zoomed out layer, where you can see the whole world.
  2. **Region view**: It shows the map of the current region, e.g. city road network.
  3. **Local view**: The layer where the actual gameplay happens. One tile of the region map correspondes to one "local" (chunk).

## Tiled for Map Scenes
With the YATI addon it is possible to import maps from the tile map generator Tiled.

- When the map gets imported only the used tiles of tile set are included. Therefore, when you want to change tiles dynamically via Godot script you can create in Tiled another auxiliary layer where you place all tiles you want to be exported somewhere and then hide the layer.