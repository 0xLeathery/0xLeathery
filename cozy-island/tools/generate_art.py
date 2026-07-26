#!/usr/bin/env python3
"""Generate Cozy Island tropical pixel art pack (32x32)."""
from __future__ import annotations

import math
import os
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites"
AUDIO_SRC = Path("/tmp/assets")
SEED = 42
random.seed(SEED)

# Art bible palette
P = {
    "sand": (232, 201, 142),
    "sand_dark": (210, 170, 110),
    "sand_light": (245, 224, 180),
    "grass": (98, 168, 88),
    "grass_dark": (70, 130, 68),
    "grass_light": (140, 196, 110),
    "forest": (52, 110, 62),
    "forest_dark": (36, 78, 48),
    "water": (72, 148, 196),
    "water_deep": (40, 100, 160),
    "water_foam": (190, 230, 245),
    "cave": (92, 74, 60),
    "cave_dark": (58, 46, 38),
    "wood": (140, 92, 48),
    "wood_dark": (96, 62, 32),
    "leaf": (56, 140, 72),
    "leaf_dark": (36, 100, 52),
    "palm": (70, 150, 80),
    "rock": (130, 130, 128),
    "rock_dark": (90, 90, 92),
    "berry": (196, 58, 70),
    "fire": (240, 140, 50),
    "fire_core": (255, 220, 120),
    "skin": (240, 196, 150),
    "hair": (70, 48, 36),
    "shirt": (90, 160, 190),
    "pants": (70, 90, 120),
    "mira_hair": (180, 90, 50),
    "mira_dress": (220, 130, 90),
    "outline": (40, 30, 24),
    "ui_bg": (61, 50, 36),
    "ui_border": (233, 166, 108),
    "ui_fill": (74, 63, 48),
    "white": (255, 248, 238),
    "transparent": (0, 0, 0, 0),
}


def new_img(w=32, h=32) -> Image.Image:
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def px(draw: ImageDraw.ImageDraw, x, y, color, size=1):
    if len(color) == 3:
        color = (*color, 255)
    draw.rectangle([x, y, x + size - 1, y + size - 1], fill=color)


def fill_rect(draw, x, y, w, h, color):
    if len(color) == 3:
        color = (*color, 255)
    draw.rectangle([x, y, x + w - 1, y + h - 1], fill=color)


def circle(draw, cx, cy, r, color):
    if len(color) == 3:
        color = (*color, 255)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=color)


def outline_rect(draw, x, y, w, h, color):
    if len(color) == 3:
        color = (*color, 255)
    draw.rectangle([x, y, x + w - 1, y + h - 1], outline=color)


def save(img: Image.Image, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)
    print("wrote", path.relative_to(ROOT))


def terrain_tile(base, dark=None, light=None, speckles=12) -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    fill_rect(d, 0, 0, 32, 32, base)
    rng = random.Random(hash(base) ^ SEED)
    if dark:
        for _ in range(speckles):
            x, y = rng.randint(0, 31), rng.randint(0, 31)
            px(d, x, y, dark)
    if light:
        for _ in range(speckles // 2):
            x, y = rng.randint(0, 31), rng.randint(0, 31)
            px(d, x, y, light)
    return img


def water_frame(frame: int) -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    fill_rect(d, 0, 0, 32, 32, P["water_deep"])
    fill_rect(d, 0, 0, 32, 20, P["water"])
    offset = frame * 3
    for i in range(5):
        y = 6 + ((i * 5 + offset) % 18)
        for x in range(0, 32, 4):
            px(d, (x + offset + i) % 32, y, P["water_foam"])
    return img


def make_tilesheet():
    tiles = []
    names = []
    # 0 sand, 1 sand dark, 2 grass, 3 forest, 4 cave, 5 dirt path
    tiles.append(terrain_tile(P["sand"], P["sand_dark"], P["sand_light"]))
    names.append("sand")
    tiles.append(terrain_tile(P["sand_dark"], P["wood"], P["sand"]))
    names.append("sand_dark")
    tiles.append(terrain_tile(P["grass"], P["grass_dark"], P["grass_light"], 18))
    names.append("grass")
    tiles.append(terrain_tile(P["forest"], P["forest_dark"], P["grass"], 20))
    names.append("forest")
    tiles.append(terrain_tile(P["cave"], P["cave_dark"], P["rock"], 16))
    names.append("cave")
    tiles.append(terrain_tile(P["wood"], P["wood_dark"], P["sand_dark"], 10))
    names.append("path")
    for i in range(4):
        tiles.append(water_frame(i))
        names.append(f"water_{i}")

    # Shore blend tiles
    shore = new_img()
    d = ImageDraw.Draw(shore)
    fill_rect(d, 0, 0, 32, 18, P["sand"])
    fill_rect(d, 0, 18, 32, 14, P["water"])
    for x in range(0, 32, 2):
        px(d, x, 17, P["sand_light"])
        px(d, x + 1, 18, P["water_foam"])
    tiles.append(shore)
    names.append("shore")

    cols = 8
    rows = math.ceil(len(tiles) / cols)
    sheet = Image.new("RGBA", (cols * 32, rows * 32), (0, 0, 0, 0))
    for i, t in enumerate(tiles):
        sheet.paste(t, ((i % cols) * 32, (i // cols) * 32))
    save(sheet, OUT / "tilesets" / "cozy_terrain.png")
    # also individual for props pipeline
    for name, t in zip(names, tiles):
        save(t, OUT / "tilesets" / "tiles" / f"{name}.png")
    return names


def draw_tree(palm=True) -> Image.Image:
    img = new_img(32, 48)
    d = ImageDraw.Draw(img)
    # trunk
    fill_rect(d, 14, 24, 5, 20, P["wood"])
    fill_rect(d, 15, 24, 2, 20, P["wood_dark"])
    if palm:
        for angle in range(-2, 3):
            for i in range(10):
                x = 16 + angle * 3 + (i if angle >= 0 else -i) // 2
                y = 22 - i * 2
                circle(d, x, y, 3, P["palm"] if i % 2 == 0 else P["leaf_dark"])
        circle(d, 16, 18, 6, P["leaf"])
    else:
        circle(d, 16, 18, 10, P["leaf_dark"])
        circle(d, 12, 16, 7, P["leaf"])
        circle(d, 20, 16, 7, P["leaf"])
        circle(d, 16, 12, 6, P["grass_light"])
    return img


def draw_bush(berry=False) -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    circle(d, 16, 20, 9, P["leaf_dark"])
    circle(d, 12, 18, 7, P["leaf"])
    circle(d, 20, 18, 7, P["leaf"])
    if berry:
        for x, y in [(12, 16), (18, 18), (15, 21), (20, 15)]:
            circle(d, x, y, 2, P["berry"])
    return img


def draw_rock() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    d.ellipse([6, 12, 26, 28], fill=P["rock_dark"])
    d.ellipse([8, 10, 24, 26], fill=P["rock"])
    d.ellipse([10, 12, 16, 18], fill=(*P["white"][:3], 90))
    return img


def draw_log() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    fill_rect(d, 4, 14, 24, 8, P["wood"])
    fill_rect(d, 4, 14, 24, 3, P["wood_dark"])
    circle(d, 4, 18, 4, P["wood_dark"])
    circle(d, 28, 18, 4, P["wood"])
    return img


def draw_stick() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    for i in range(18):
        px(d, 8 + i, 20 - i // 3, P["wood"] if i % 2 == 0 else P["wood_dark"])
    return img


def draw_vine() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    for i in range(20):
        px(d, 14 + int(math.sin(i / 2) * 3), 6 + i, P["leaf"])
        if i % 4 == 0:
            circle(d, 14 + int(math.sin(i / 2) * 3) + 2, 6 + i, 2, P["leaf_dark"])
    return img


def draw_fish() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    d.ellipse([8, 12, 24, 22], fill=P["water"])
    d.polygon([(24, 17), (30, 12), (30, 22)], fill=P["water_deep"])
    px(d, 12, 15, P["white"])
    px(d, 11, 15, P["outline"])
    return img


def draw_water_spot() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    d.ellipse([4, 10, 28, 26], fill=P["water_deep"])
    d.ellipse([8, 12, 24, 22], fill=P["water"])
    for x in (10, 16, 22):
        px(d, x, 14, P["water_foam"])
    return img


def draw_flint() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    d.polygon([(10, 24), (16, 8), (24, 24)], fill=P["rock_dark"])
    d.polygon([(12, 22), (16, 12), (20, 22)], fill=P["rock"])
    return img


def draw_clay() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    d.ellipse([8, 14, 24, 26], fill=(160, 90, 50))
    d.ellipse([10, 16, 18, 22], fill=(180, 110, 70))
    return img


def draw_ore() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    d.ellipse([8, 12, 24, 26], fill=P["rock_dark"])
    for x, y in [(12, 16), (18, 18), (15, 20)]:
        px(d, x, y, (180, 190, 200), 2)
    return img


def draw_fire() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    # stones
    for x in (8, 14, 20):
        circle(d, x + 2, 26, 3, P["rock"])
    # flames
    d.polygon([(16, 6), (10, 22), (22, 22)], fill=P["fire"])
    d.polygon([(16, 10), (13, 22), (19, 22)], fill=P["fire_core"])
    return img


def draw_bed() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    fill_rect(d, 4, 12, 24, 14, P["wood"])
    fill_rect(d, 6, 14, 20, 10, P["mira_dress"])
    fill_rect(d, 6, 14, 8, 10, P["white"])
    outline_rect(d, 4, 12, 24, 14, P["outline"])
    return img


def draw_crate() -> Image.Image:
    img = new_img()
    d = ImageDraw.Draw(img)
    fill_rect(d, 6, 10, 20, 16, P["wood"])
    fill_rect(d, 6, 10, 20, 4, P["wood_dark"])
    outline_rect(d, 6, 10, 20, 16, P["outline"])
    px(d, 15, 16, P["outline"], 2)
    return img


def draw_workshop() -> Image.Image:
    img = new_img(48, 40)
    d = ImageDraw.Draw(img)
    fill_rect(d, 4, 16, 40, 18, P["wood"])
    fill_rect(d, 8, 8, 32, 12, P["wood_dark"])
    # awning
    fill_rect(d, 6, 6, 36, 6, P["mira_dress"])
    outline_rect(d, 4, 16, 40, 18, P["outline"])
    # tools
    fill_rect(d, 14, 20, 2, 10, P["rock"])
    fill_rect(d, 28, 22, 8, 3, P["wood_dark"])
    return img


def draw_character(frame: int, direction: str, mira=False) -> Image.Image:
    img = new_img(32, 32)
    d = ImageDraw.Draw(img)
    bob = 0 if frame % 2 == 0 else 1
    # legs
    leg_off = (-1, 1, -1, 1)[frame]
    pant = P["mira_dress"] if mira else P["pants"]
    fill_rect(d, 12, 22 + bob, 3, 6, pant)
    fill_rect(d, 17, 22 + bob, 3, 6, pant)
    if direction in ("down", "up"):
        fill_rect(d, 12 + leg_off, 22 + bob, 3, 6, pant)
        fill_rect(d, 17 - leg_off, 22 + bob, 3, 6, pant)
    # body
    shirt = P["mira_dress"] if mira else P["shirt"]
    fill_rect(d, 11, 14 + bob, 10, 10, shirt)
    # head
    circle(d, 16, 10 + bob, 5, P["skin"])
    hair = P["mira_hair"] if mira else P["hair"]
    if direction != "up":
        fill_rect(d, 11, 5 + bob, 10, 4, hair)
        if mira:
            fill_rect(d, 10, 8 + bob, 3, 6, hair)
            fill_rect(d, 19, 8 + bob, 3, 6, hair)
    else:
        fill_rect(d, 11, 5 + bob, 10, 6, hair)
    # face
    if direction == "down":
        px(d, 14, 10 + bob, P["outline"])
        px(d, 18, 10 + bob, P["outline"])
        px(d, 16, 12 + bob, (200, 120, 100))
    elif direction == "left":
        px(d, 13, 10 + bob, P["outline"])
    elif direction == "right":
        px(d, 18, 10 + bob, P["outline"])
    # outline feet
    fill_rect(d, 12, 27 + bob, 3, 2, P["wood_dark"])
    fill_rect(d, 17, 27 + bob, 3, 2, P["wood_dark"])
    return img


def make_player_sheet():
    dirs = ["down", "left", "right", "up"]
    frames = 4
    sheet = Image.new("RGBA", (32 * frames, 32 * len(dirs)), (0, 0, 0, 0))
    for dy, direction in enumerate(dirs):
        for fx in range(frames):
            frame = draw_character(fx, direction, mira=False)
            sheet.paste(frame, (fx * 32, dy * 32))
            save(frame, OUT / "characters" / "player" / f"{direction}_{fx}.png")
    save(sheet, OUT / "characters" / "player_sheet.png")

    mira_sheet = Image.new("RGBA", (32 * frames, 32 * len(dirs)), (0, 0, 0, 0))
    for dy, direction in enumerate(dirs):
        for fx in range(frames):
            frame = draw_character(fx, direction, mira=True)
            mira_sheet.paste(frame, (fx * 32, dy * 32))
    save(mira_sheet, OUT / "characters" / "mira_sheet.png")
    # idle front for NPC
    save(draw_character(0, "down", mira=True), OUT / "characters" / "mira.png")


def make_props():
    props = {
        "palm_tree": draw_tree(True),
        "round_tree": draw_tree(False),
        "bush": draw_bush(False),
        "berry_bush": draw_bush(True),
        "rock": draw_rock(),
        "log": draw_log(),
        "stick": draw_stick(),
        "vine": draw_vine(),
        "fish": draw_fish(),
        "water_spot": draw_water_spot(),
        "flint": draw_flint(),
        "clay": draw_clay(),
        "iron_ore": draw_ore(),
        "fire_pit": draw_fire(),
        "bed": draw_bed(),
        "storage_crate": draw_crate(),
        "workshop": draw_workshop(),
    }
    for name, img in props.items():
        save(img, OUT / "props" / f"{name}.png")
    return props


def icon_from_color(color, shape="circle") -> Image.Image:
    img = new_img(32, 32)
    d = ImageDraw.Draw(img)
    if shape == "circle":
        circle(d, 16, 16, 10, color)
        circle(d, 13, 13, 3, P["white"])
    elif shape == "rect":
        fill_rect(d, 8, 8, 16, 16, color)
        outline_rect(d, 8, 8, 16, 16, P["outline"])
    elif shape == "diamond":
        d.polygon([(16, 6), (26, 16), (16, 26), (6, 16)], fill=color)
    return img


def make_item_icons(props: dict):
    mapping = {
        "stick": props["stick"],
        "log": props["log"],
        "vine": props["vine"],
        "stone": props["rock"],
        "flint": props["flint"],
        "berry": None,
        "fish": props["fish"],
        "fresh_water": props["water_spot"],
        "clay": props["clay"],
        "iron_ore": props["iron_ore"],
    }
    # berry icon
    berry = new_img()
    d = ImageDraw.Draw(berry)
    for x, y in [(12, 14), (18, 14), (15, 18)]:
        circle(d, x, y, 4, P["berry"])
    mapping["berry"] = berry

    # generate remaining from color tags
    colors = {
        "rope": P["sand_dark"],
        "knife": P["rock"],
        "bowl": (160, 90, 50),
        "axe": P["rock"],
        "spear": P["wood"],
        "berry_mash": P["berry"],
        "grilled_fish": P["fire"],
        "campfire_meal": P["fire_core"],
        "woven_mat": P["sand"],
        "storage_bag": P["wood"],
        "charcoal": P["outline"],
        "preserved_fish": P["water_deep"],
        "trap": P["wood_dark"],
        "raft_frame": P["wood"],
        "scrap": P["rock_dark"],
        "torch": P["fire"],
        "workbench": P["wood"],
        "kiln_brick": (150, 70, 50),
        "jar": P["water"],
        "cooked_clay_bowl": (180, 80, 60),
    }
    for item_id, img in mapping.items():
        save(img, OUT / "items" / f"{item_id}.png")
    for item_id, color in colors.items():
        shape = "diamond" if item_id in ("knife", "axe", "spear") else "circle"
        save(icon_from_color(color, shape), OUT / "items" / f"{item_id}.png")


def make_ui():
    panel = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    d = ImageDraw.Draw(panel)
    fill_rect(d, 0, 0, 96, 96, P["ui_bg"])
    outline_rect(d, 0, 0, 96, 96, P["ui_border"])
    outline_rect(d, 2, 2, 92, 92, P["ui_fill"])
    save(panel, OUT / "ui" / "panel_9slice.png")

    btn = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(btn)
    fill_rect(d, 0, 0, 48, 48, P["ui_fill"])
    outline_rect(d, 0, 0, 48, 48, P["ui_border"])
    save(btn, OUT / "ui" / "button.png")

    btn_h = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(btn_h)
    fill_rect(d, 0, 0, 48, 48, P["ui_border"])
    outline_rect(d, 0, 0, 48, 48, P["white"])
    save(btn_h, OUT / "ui" / "button_hover.png")

    # joystick
    base = new_img(64, 64)
    d = ImageDraw.Draw(base)
    circle(d, 32, 32, 28, (*P["ui_bg"], 160))
    circle(d, 32, 32, 28, (*P["ui_border"], 80))
    save(base, OUT / "ui" / "joystick_base.png")
    knob = new_img(32, 32)
    d = ImageDraw.Draw(knob)
    circle(d, 16, 16, 12, P["ui_border"])
    circle(d, 13, 13, 4, P["white"])
    save(knob, OUT / "ui" / "joystick_knob.png")


def copy_audio():
    dest = ROOT / "assets" / "audio"
    dest.mkdir(parents=True, exist_ok=True)
    mapping = {
        "gather.ogg": AUDIO_SRC / "impact/Audio/impactWood_light_001.ogg",
        "ui_click.ogg": AUDIO_SRC / "interface/Audio/click_002.ogg",
        "ui_open.ogg": AUDIO_SRC / "interface/Audio/switch_001.ogg",
        "footstep.ogg": AUDIO_SRC / "impact/Audio/footstep_carpet_001.ogg",
        "soft.ogg": AUDIO_SRC / "impact/Audio/impactSoft_medium_004.ogg",
    }
    # find available click sounds
    iface = list((AUDIO_SRC / "interface/Audio").glob("*.ogg")) if (AUDIO_SRC / "interface/Audio").exists() else []
    if iface:
        mapping["ui_click.ogg"] = iface[0]
        mapping["ui_open.ogg"] = iface[min(1, len(iface) - 1)]
    for name, src in mapping.items():
        if src.exists():
            data = src.read_bytes()
            (dest / name).write_bytes(data)
            print("copied audio", name)


def write_art_bible():
    text = """# Cozy Island Art Bible

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
1. Terrain TileMap (sand/grass/forest/cave/water)
2. Shore / path accents
3. Props (trees, rocks, bushes)
4. Gatherables / buildings / NPCs
5. Player
6. VFX (fire particles, water shimmer)
7. UI CanvasLayer

## Credits
- Custom tropical sprites generated for Cozy Island
- UI / SFX accents from [Kenney.nl](https://kenney.nl) (CC0)
"""
    path = ROOT / "docs" / "ART_BIBLE.md"
    path.write_text(text)
    print("wrote", path)


def main():
    print("Generating Cozy Island art pack...")
    make_tilesheet()
    make_player_sheet()
    props = make_props()
    make_item_icons(props)
    make_ui()
    copy_audio()
    write_art_bible()
    print("Done.")


if __name__ == "__main__":
    main()
