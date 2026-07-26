# Publishing Cozy Island on itch.io

Play in the browser on desktop or phone — no install required.

## Quick upload (manual, ~5 minutes)

### 1. Create the web build (if not already built)

In Godot 4.3:

1. **Editor → Manage Export Templates → Download**
2. **Project → Export → Web**
3. Export to `build/web/index.html`

Or from the command line (Linux/macOS):

```bash
godot --headless --path cozy-island --export-release "Web" cozy-island/build/web/index.html
```

### 2. Zip the web folder

The zip must contain `index.html` at the **root** (not inside a subfolder).

```bash
cd cozy-island/build/web
zip -r ../cozy-island-web.zip .
```

A pre-built zip path: `cozy-island/build/cozy-island-web.zip` (generate locally; not committed to git due to size).

### 3. Create your itch.io page

1. Go to [itch.io/dashboard](https://itch.io/dashboard) (you’re signed in via GitHub as **0xLeathery**)
2. **Create new project**
3. Set the page URL to **`0xleathery/cozy-island`** (itch lowercases usernames)
4. **Kind of project:** HTML
5. **Upload** `cozy-island-web.zip`
6. Check **"This file will be played in the browser"**
7. Set viewport: **1280 × 720**
8. Check **"Mobile friendly"**
9. **Save** → set visibility to **Public** or **Restricted** (link-only) → **Publish**

Your game URL:

**https://0xleathery.itch.io/cozy-island**

> If your itch username differs, check your profile URL at itch.io/profile — use that slug instead.

---

## Upload with Butler (automated)

[Butler](https://itch.io/docs/butler/) is itch’s CLI uploader.

### One-time setup

```bash
# Install butler — see https://itch.io/docs/butler/installing.html
butler login
```

### Configure project slug

Edit `.itch.toml` if your itch username differs:

```toml
project = "0xleathery/cozy-island"
```

### Build and push

```bash
cd cozy-island
godot --headless --export-release "Web" build/web/index.html
cd build/web && zip -r ../cozy-island-web.zip .
cd ../..
butler push build/cozy-island-web.zip 0xleathery/cozy-island:web
```

---

## Controls (browser)

### Desktop
| Key | Action |
|-----|--------|
| WASD | Move |
| E / Space | Interact |
| C | Craft |
| I | Inventory |
| R | Research |
| F | Sleep |

### Phone / tablet
Virtual joystick (left) and action buttons (right) appear automatically when a touchscreen is detected.

**Tip:** On iPhone, open the itch.io page in Safari and use landscape orientation.

---

## Troubleshooting

### Game stuck on loading
- Wait 10–20 seconds on first load (WASM is ~34 MB)
- Try Chrome or Firefox; Safari on iOS works but can be slower

### Touch controls missing
- Enable **Mobile friendly** on the itch.io edit page
- Rotate to landscape

### “Failed to fetch” / blank screen
- Ensure the uploaded zip has `index.html` at the root
- Re-export with matching Godot 4.3 export templates

---

## Notes

- itch.io hosts the HTML5 build; no Mac or Xcode needed for players
- The web build is separate from the iOS native export ([IOS.md](IOS.md))
- Free itch.io accounts can host HTML games with reasonable bandwidth limits
