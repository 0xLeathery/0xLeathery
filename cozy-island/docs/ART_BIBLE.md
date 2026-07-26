# Cozy Island Art Bible

## Style
- Top-down tropical pixel art
- Tile size: **32×32**
- Character size: **32×32** (props may be taller)
- Filter: Nearest (no smoothing)
- Warm coastal palette (sunset sand, soft greens, turquoise water)

## Palette
| Token | Hex-ish | Use |
|-------|---------|-----|
| sand | #E8C98E | Beach |
| grass | #62A858 | Clearings |
| forest | #346E3E | Inland |
| water | #4894C4 | River / ocean |
| wood | #8C5C30 | Props / camp |
| accent | #E9A66C | UI borders / fire |

## Layers
1. Atmosphere (WorldEnvironment glow, sparkles, leaf dust)
2. Terrain TileMap (sand/grass/forest/cave/water)
3. Shore / path accents
4. Props (trees, rocks, bushes) + soft shadows
5. Gatherables / buildings / NPCs
6. Player (walk + gather sheets)
7. Campfire PointLight2D + fire particles
8. Day/night CanvasModulate grades
9. UI CanvasLayer (textured panels / joystick)

## Animation
- Player sheet: 128×160 — 4 walk rows × 4 frames + gather row
- Fire pit sheet: 128×32 — 4 burn frames
- Water tiles: atlas frames 6–9 cycle every ~220ms

## Credits
- Custom tropical sprites generated for Cozy Island
- UI / SFX accents from [Kenney.nl](https://kenney.nl) (CC0)
