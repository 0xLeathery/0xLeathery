# Running Cozy Island on iPhone

Cozy Island can be exported to iPhone from a **Mac** using Godot 4.3 and Xcode. Touch controls (virtual joystick + action buttons) are included and appear automatically on iOS.

## Requirements

| Item | Details |
|------|---------|
| **Mac** | macOS with Xcode installed (required for iOS builds) |
| **Xcode** | 15+ recommended, from the Mac App Store |
| **Godot** | 4.3.x (match project version) |
| **Apple ID** | Free account works for testing on your own device (~7 days) |
| **iPhone** | iOS 14.0 or later |
| **USB cable** | To connect iPhone to Mac |

Optional for longer testing or TestFlight: **Apple Developer Program** ($99/year).

---

## One-time setup

### 1. Install Godot export templates

In Godot: **Editor → Manage Export Templates → Download and Install**

### 2. Clone / pull the project

```bash
git clone https://github.com/0xLeathery/0xLeathery.git
cd 0xLeathery/cozy-island
```

Open `project.godot` in Godot.

### 3. Configure the iOS export preset

The project includes `export_presets.cfg` with a starter iOS preset.

1. **Project → Export**
2. Select **iOS**
3. Set **Application → Bundle Identifier** to something unique, e.g. `com.yourname.cozyisland`
4. Under **Options → Architectures**, ensure **arm64** is enabled

### 4. Export the Xcode project

1. **Project → Export → iOS**
2. Export to e.g. `build/ios/CozyIsland.xcodeproj`
3. Godot generates an Xcode project (not a standalone `.ipa` yet)

---

## Install on your iPhone

### 1. Open in Xcode

Double-click the exported `.xcodeproj` in Xcode.

### 2. Sign the app

1. Select the project in the left sidebar
2. **Signing & Capabilities** tab
3. Check **Automatically manage signing**
4. Choose your **Team** (your Apple ID)
5. Set **Bundle Identifier** to match Godot (must be unique per Apple account)

### 3. Connect your iPhone

1. Plug iPhone into Mac via USB
2. On iPhone: tap **Trust This Computer** if prompted
3. In Xcode’s device dropdown (top toolbar), select your iPhone

### 4. Run

Click the **Run** (▶) button in Xcode. The first build can take several minutes.

### 5. Trust the developer (first install only)

On iPhone:

**Settings → General → VPN & Device Management → [Your Apple ID] → Trust**

Then launch **Cozy Island** from the home screen.

---

## Touch controls on iPhone

When running on iOS, you’ll see:

| Control | Action |
|---------|--------|
| **Left joystick** | Move |
| **E** button | Interact / gather |
| **C** button | Crafting grid |
| **I** button | Inventory |
| **R** button | Research & helpers |
| **F** button | Sleep (at camp bed) |

Hold the phone in **landscape** for the best layout.

---

## Iterating during development

After code changes in Godot:

1. Re-export the iOS project (**Project → Export**)
2. In Xcode, **Run** again (⌘R)

Tip: keep Xcode open and re-export from Godot when you change scripts or scenes.

---

## Troubleshooting

### “Failed to register bundle identifier”
Use a unique bundle ID, e.g. `com.ethanhurst.cozyisland`.

### “Untrusted Developer”
Trust your certificate under **Settings → General → VPN & Device Management**.

### App expires after ~7 days
Free Apple IDs limit sideloaded apps. Re-run from Xcode, or join the paid Developer Program.

### Black screen or crash on launch
- Confirm Godot **4.3** export templates match the editor version
- Check Xcode **Console** for crash logs
- Ensure **arm64** is the only architecture for device builds

### Touch controls not showing
They enable when Godot detects iOS or a touchscreen. On simulator, use **I/O → Touchscreen** in the simulator menu if needed.

---

## TestFlight (optional, wider testing)

Requires a paid Apple Developer account:

1. Archive in Xcode: **Product → Archive**
2. Upload to App Store Connect
3. Add testers in **TestFlight**

---

## What you cannot do from Windows/Linux alone

iOS builds **must** be compiled on a Mac with Xcode. There is no way to install directly to iPhone from a PC without a Mac build step (or a cloud Mac service like MacStadium / GitHub macOS runners).
