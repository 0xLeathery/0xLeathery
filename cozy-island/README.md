# Cozy Island

A cozy survival-crafting game blending **Lost in Blue** (island exploration & soft survival), **Dawn of Crafting** (experimental recipe discovery), and **Armory & Machine** (camp automation & research).

Built with **Godot 4.3** and GDScript.

## Quick Start

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Open `cozy-island/project.godot` in the Godot editor
3. Press **F5** to run

### Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| E / Space | Interact / Gather |
| C | Crafting grid |
| I | Inventory |
| R | Research & helpers |
| F | Sleep (near bed at camp) |

## Features

- **Soft survival** — hunger, thirst, and energy with Relaxed Mode toggle
- **Island zones** — beach, forest, river, camp cave
- **40 recipes** — experiment to discover hidden combinations
- **Skills** — woodworking, cooking, stonework, weaving
- **Camp building** — fire pit, bed, storage, workshop
- **Automation** — assign helpers to gather, fish, tend fire, and more
- **Research tree** — 8 unlock nodes including raft blueprint

## Project Structure

```
cozy-island/
├── data/           # JSON items, recipes, research
├── scenes/         # Godot scenes
├── scripts/        # GDScript systems
├── assets/         # Sprites and audio placeholders
└── docs/GDD.md     # Game design document
```

## Development

Game data lives in JSON under `data/` for easy balancing without recompiling.

Autoload singletons:
- `GameState` — inventory, meters, time, skills, helpers
- `EventBus` — decoupled game events
- `ItemDatabase` / `RecipeRegistry` / `ResearchRegistry` — data loaders

## License

MIT — see repository root for details.
