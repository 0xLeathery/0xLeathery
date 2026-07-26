# Publishing Cozy Island on itch.io

Play in the browser on desktop or phone — no install required.

**Live URL:** https://leathery.itch.io/cozy-island

---

## One-time setup (Butler + API key)

### 1. Create an itch.io API key

1. Go to [itch.io/user/settings/api-keys](https://itch.io/user/settings/api-keys)
2. **Generate new API key** → copy it (shown once)

### 2. Add the key to GitHub (for automatic deploys)

1. Open [github.com/0xLeathery/0xLeathery/settings/secrets/actions](https://github.com/0xLeathery/0xLeathery/settings/secrets/actions)
2. **New repository secret**
3. Name: `ITCH_API_KEY`
4. Value: paste your itch API key

After this, every push to **`main`** that changes `cozy-island/` will build and publish automatically.

### 3. Create the itch.io project page (first time only)

Before Butler can push, the project must exist on itch:

1. [itch.io/dashboard](https://itch.io/dashboard) → **Create new project**
2. URL slug: **`cozy-island`**
3. Kind: **HTML**
4. Save as draft (Butler will upload the zip on first push)

---

## Publish with Butler

### Option A — GitHub Actions (recommended)

**Automatic:** merge to `main` → workflow builds & pushes via Butler.

**Manual:** [Actions → Export & Publish to itch.io → Run workflow](https://github.com/0xLeathery/0xLeathery/actions/workflows/itch-export.yml)

Uncheck “Push build to itch.io” if you only want the zip artifact.

### Option B — Local script

```bash
cd cozy-island

# Install Butler (once)
chmod +x scripts/install-butler.sh scripts/publish-itch.sh
./scripts/install-butler.sh
export PATH="$PWD/tools/butler:$PATH"

# Authenticate (once) — opens browser or prompts for API key
butler login

# Build + publish
./scripts/publish-itch.sh
```

Re-publish without rebuilding:

```bash
./scripts/publish-itch.sh --skip-build
```

### Option C — Butler CLI directly

```bash
godot --headless --path cozy-island --export-release "Web" cozy-island/build/web/index.html
cd cozy-island/build/web && zip -r ../cozy-island-web.zip .
butler push ../cozy-island-web.zip leathery/cozy-island:web
butler status leathery/cozy-island:web
```

---

## itch.io page settings (check after first upload)

On your [project edit page](https://itch.io/game/edit/):

| Setting | Value |
|---------|-------|
| Kind | HTML |
| **This file will be played in the browser** | ✅ |
| **Mobile friendly** | ✅ |
| Viewport | 1280 × 720 |
| Orientation | Landscape |

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

### GitHub Action fails: “ITCH_API_KEY secret is not set”
Add the secret (see setup step 2 above).

### Butler: “Project not found”
Create the draft project on itch.io first (setup step 3).

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

- Config: [`/.itch.toml`](../.itch.toml) and [`scripts/publish-itch.sh`](../scripts/publish-itch.sh)
- itch.io hosts the HTML5 build; no Mac or Xcode needed for players
- Native iOS build: [IOS.md](IOS.md)
