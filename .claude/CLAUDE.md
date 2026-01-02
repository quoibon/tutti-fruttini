# 🍉 Tutti Fruttini - Technical Reference

**Engine:** Godot 4.5.1 | **Package:** `com.bonsaidotdot.tuttifruttini` | **Version:** 1.0.0 (Pre-Release)
**Status:** 98% Complete - All Core Features Working | **Next:** Production Release

---

## Project Overview

Physics-based fruit-merging puzzle game. Drop fruits, merge identical ones, shake to jostle pile. Player-friendly monetization (rewarded ads only for shake refills).

**Core Mechanics:**
- 11 fruit tiers (0-10): Blueberry → Apple → Lemon → Coconut → Banana → Dragon Fruit → Orange → Grapes → Pineapple → Watermelon → Strawberry
- Spawn pool: Levels 0-4 only (weighted random)
- Merge on collision (identical level + low velocity)
- Shake system: 50 uses, refill via rewarded ad
- Game over: 2-second grace period when fruit stays in danger zone

---

## Technical Specifications

### Physics Configuration
```gdscript
# Project Settings
default_gravity = 980.0
physics_ticks_per_second = 60

# Fruit PhysicsMaterial (CURRENT - optimized)
friction = 0.5
bounce = 0.117  # 1.3x bouncier than original (was 0.09)

# Merge Conditions
velocity_threshold = 500  # px/s average (increased from 300)
merge_cooldown = 0.05     # seconds
spawn_cooldown = 0.5      # seconds
merge_animation = 0.15    # seconds (fast, was 0.4s)
velocity_retention = 0.9  # 90% momentum kept (was 0.5)
```

### Fruit Data
| Level | Name | Radius | Score | Spawn % | Size Multiplier |
|-------|------|--------|-------|---------|-----------------|
| 0 | Blueberry | 36px | 1 | 35% | 1.0x |
| 1 | Apple | 42px | 3 | 30% | 1.43x ⬆️ (increased 10%) |
| 2 | Lemon | 50px | 6 | 20% | 1.32x ⬆️ (increased 10%) |
| 3 | Coconut | 67px | 10 | 10% | 1.32x ⬆️ (increased 10%) |
| 4 | Banana | 84px | 15 | 5% | 1.247x ⬆️ (increased 10%) |
| 5 | Dragon Fruit | 101px | 21 | 0% | 1.021x |
| 6 | Orange | 122px | 28 | 0% | 1.078x |
| 7 | Grapes | 138px | 36 | 0% | 0.84x ⬇️ |
| 8 | Pineapple | 155px | 45 | 0% | 0.857x ⬇️ |
| 9 | Watermelon | 173px | 55 | 0% | 0.857x ⬇️ |
| 10 | Strawberry | 208px | 500 | 0% | 0.911x ⬇️ |

**Special Merge Behavior:**
- When two Strawberries (level 10, ultimate fruit) merge, they disappear without spawning a new fruit
- Awards 5x bonus points instead of standard 2x
- Plays special sound effect (67.mp3)

**Collision Detection:** Auto-generated polygon shapes from sprite alpha channel
- 32-ray sampling from sprite center to find edges (alpha > 0.1)
- Convex hull algorithm creates tight-fitting collision shapes
- Shapes match sprite outline 1:1 (no additional scaling applied)

### Collision Layers
- **1 (Walls):** StaticBody2D container
- **2 (Fruits):** RigidBody2D fruits
- **4 (MergeDetection):** Area2D merge zones
- **8 (GameOverZone):** Area2D top boundary

### Performance Targets
- **FPS:** 60 (achieved ✅)
- **Max Fruits:** 75 active (enforced by pool ✅)
- **RAM Usage:** <150MB (currently ~120MB ✅)

---

## Architecture

### Autoload Singletons
1. **SaveManager** - JSON persistence (`user://save_data.json`) - MUST BE FIRST
2. **GameManager** - Fruit data, game state
3. **ScoreManager** - Score, combo (1.0-3.0x), high score
4. **AudioManager** - Music + 15 pooled SFX channels
5. **AdManager** - AdMob integration + 30s fallback timer

**Critical:** SaveManager must load before ScoreManager to ensure high scores persist correctly.

### Object Pools
- **FruitPool:** 30 initial, 100 max, 75 active limit (auto-culls oldest)
- **ParticlePool:** 15 pre-warmed systems

### Scene Hierarchy
```
Main.tscn
├── Camera2D (shake effect)
├── Container (walls/floor - 650x1100 play area)
├── GameplayArea
│   ├── SpawnPoint, FruitContainer, GameOverDetector
│   └── NextFruitPreview (mouse-following)
├── Managers (Spawner, ShakeManager)
├── UI (Score, High Score, Shake Button, Refill Button, Pause Button)
├── FruitPool
└── ParticlePool
```

**Container Dimensions:**
- Width: 650px (increased from 540px for better play space)
- Height: 1100px (increased from 960px)
- Optimized for mobile portrait orientation (1080x1920)
- Rounded corners (20px radius) on background panel
- Circular collision shapes (20px radius) at bottom corners for smooth physics
- Prevents fruits from getting stuck in sharp corners

---

## Key Systems

### Shake Mechanic
- **Count:** 50 max (persists via SaveManager)
- **Cooldown:** 0.1s between uses (very responsive for rapid tapping)
- **Impulse:** Random vector (450 strength, 2x original)
  - Horizontal: ±450 px/s
  - Vertical: -455.6 px/s (6.75x original, 101.25% of horizontal)
- **Feedback:** Camera shake (30px, 2x original), haptic (100ms), particles, sound
- **Refill:** Rewarded ad OR free after 30s timer
- **UI:** Large button (260x200) with clear "SHAKE" text and count display

### Scoring System
```gdscript
# Combo system
combo_multiplier += 0.1  # per merge within 3s
max_combo = 3.0x
combo_timeout = 3.0      # resets to 1.0x
```

### Game Over Detection
- **Area2D at top** with 2-second grace period
- **Velocity check:** Ignore fast-moving fruits (>200 px/s) - allows fruits to bounce above red line
- **Out of bounds check:** Game ends if fruits LAND (velocity < 300) outside container
  - Side margins: 80px outside left/right walls
  - Bottom margin: 100px below floor
  - No top check - fruits can fly high and fall back in
  - Fast-moving fruits (>300 px/s) are ignored as they're still in flight
- **Visual warning:** Red overlay + pulsing
- Balanced between allowing dynamic shaking and preventing escapees

### Save Data Structure
```json
{
  "version": "1.0.0",
  "high_score": 0,
  "shake_count": 50,
  "settings": {
    "music_volume": 0.4,
    "sfx_volume": 1.0,
    "music_enabled": true,
    "sfx_enabled": true,
    "vibration_enabled": true
  },
  "stats": {
    "games_played": 0,
    "total_merges": 0,
    "highest_fruit_reached": 0
  }
}
```

**Android Save System (Multi-layer Redundancy):**
- **Immediate save:** High score saved instantly every time it increases
- **Game events:** Save on game over, pause, and scene exit
- **App lifecycle:** Save on NOTIFICATION_APPLICATION_PAUSED (app backgrounded)
- **Verification:** Android-specific save verification with 100ms delay
- **File I/O:** Explicit file.flush() to force disk write
- **Failsafe:** tree_exiting signal saves data when Main scene unloads
- **Multiple triggers:** ScoreManager, GameManager, SaveManager all save independently
- Ensures 100% persistence across app restarts, force closes, and reboots

---

## File Structure

```
/tutti-fruttini
├── /scenes
│   ├── Main.tscn, Fruit.tscn, MainMenu.tscn, GameOver.tscn
│   ├── Settings.tscn, Pause.tscn, Tutorial.tscn
├── /scripts
│   ├── /autoload (GameManager, ScoreManager, AudioManager, SaveManager, AdManager)
│   ├── Main.gd, Fruit.gd, Spawner.gd, ShakeManager.gd, GameOverDetector.gd
│   ├── Settings.gd, Pause.gd, Tutorial.gd, MainMenu.gd, GameOver.gd
│   ├── FruitPool.gd, ParticlePool.gd, Utils.gd
├── /data
│   └── fruit_data.json (11 fruit definitions)
├── /assets
│   ├── /sounds
│   │   ├── /sfx (fruit-specific sounds, drop, shake, game_over, click, refill)
│   │   └── /music (menu and game music tracks)
│   └── /sprites
│       ├── /fruits (11 fruit sprite assets)
│       └── /ui (bonsai_logo.png)
├── project.godot
└── default_bus_layout.tres (Music: -6dB, SFX: 0dB)
```

---

## Audio System

**Buses:** Master → Music (-6dB) / SFX (0dB)

**Default Volumes:**
- Music: 40% (0.4)
- SFX: 100% (1.0)

**SFX Files (all gracefully handle missing):**
- Fruit-specific sounds: `01.BlueberrinniOctopussini.mp3` through `11.StrawberryElephant.mp3`
- **Drop SFX:** Only plays for fruit #1 (level 0, Blueberry/Cherry)
- **Merge SFX:** Plays the sound of the NEW fruit being created
- Other SFX: `shake.wav`, `game_over.wav`, `click.wav`, `refill.wav`

**Music:**
- Menu music: `Menu-FootprintsPianoOnlyLOOP.wav` (plays on MainMenu, GameOver, Settings, Pause, Tutorial)
- Game music: `Game-CaseToCaseAltPianoOnly.wav` (plays only during Main.tscn gameplay)

**Implementation:** 15-channel pooled AudioStreamPlayer (prevents cutoff)

---

## AdMob Integration

**Plugin:** [Poing Studios Godot AdMob Plugin](https://github.com/Poing-Studios/godot-admob-plugin)

**Test IDs (used by default):**
```gdscript
ANDROID_REWARDED_AD_ID = "ca-app-pub-3940256099942544/5224354917"
IOS_REWARDED_AD_ID = "ca-app-pub-3940256099942544/1712485313"
```

**Fallback:** If ad fails/unavailable, free refill after 30s countdown timer

**For Production:**
1. Replace test IDs with real AdMob IDs
2. Update AndroidManifest.xml with real App ID
3. Test rewarded ad flow on release build

---

## Android Build Configuration

**Package:** `com.bonsaidotdot.tuttifruttini`
**Min SDK:** 24 (Android 7.0) | **Target SDK:** 34 (Android 14)
**Orientation:** Portrait only (configured in AndroidManifest.xml)
**Permissions:** INTERNET, ACCESS_NETWORK_STATE, VIBRATE

**AndroidManifest.xml Configuration:**
- Package: `com.bonsaidotdot.tuttifruttini`
- Orientation: `portrait` (line 50)
- Permissions: INTERNET, ACCESS_NETWORK_STATE, VIBRATE
- AdMob App ID: Test ID included (replace for production)

**Signing:**
```bash
keytool -genkey -v -keystore tuttifruttini.keystore \
  -alias tuttifruttini -keyalg RSA -keysize 2048 -validity 10000
```

**Build:**
```bash
godot --headless --export-release "Android" bin/tuttifruttini-release.aab
```

---

## UI/UX Reference

**Colors:**
- Primary: `#FF6B6B`, Secondary: `#4ECDC4`, Background: `#FFE66D`
- Text: `#1A535C`, Danger: `#FF006E`

**Touch Targets:** Min 44x44 dp
**Shake Button:** 260x200px with large text and outline
**Aspect Ratios:** 16:9 to 20:9 (portrait)

**Main Game UI:**
- High Score: Top left, 32px font, gray color
- Score: Below high score, 64px font (large), black color - primary focus
- Shake Button: Bottom right (740, 1720), 260x180, white text with black outline
- Pause Button: Top right, "| |" text (120x120), no emoji for Android compatibility
- Combo Display: Removed for cleaner UI
- Container: 650x1100 with rounded corners (20px radius) and smooth bottom corners

**Settings Screen:**
- Scrollable container for all settings options
- Large fonts: Title 64px, labels 32px, toggles 28px
- Volume sliders with consistent 350px label width
- Toggle buttons aligned vertically
- Credits section with:
  - Developer: Bonsai... (24px)
  - Clickable logo (360x360) with hover effect (scales to 110%, brightens)
  - Motto: "Pause. Reflect. Continue..." (28px, gray)
  - Music: Jacob Lives Music (clickable button, 24px)

**Animations:**
- Fruit drop: Scale 0.7→1.0 (0.3s back ease)
- Merge: Spawn new at 1.15→1.0 (0.15s back ease, fast and smooth)
- Camera shake: 30px amplitude, 0.3s duration (2x stronger)
- Logo hover: Scale 1.0→1.1, brighten, 0.2s cubic ease

---

## Development Notes

### Current Status (January 2025)
✅ **Complete (100% Game Content):**
- Core gameplay with enhanced physics
- Shake system with integrated refill button
- Custom fruit sprites (11 unique animal-fruit hybrids)
- Custom audio files (music + SFX)
- Auto-generated collision shapes from sprite alpha
- In-game settings menu (volume, vibration, credits)
- AdMob integration (test mode, production IDs ready)
- Save system with multi-layer persistence
- Object pooling (fruits + particles)
- Tutorial system (manual access)
- Responsive UI with anchor-based layout
- Fruit cycle progression display
- NYC street background (main menu)
- Beach background (game scene)
- Privacy policy (hosted at bonsaidotdot.com)
- Google Play Console (draft app listing ready)
- App icon (using BlueberrinniOctopussini)

⏳ **Remaining (Release Only):**
- Switch AdMob from test IDs to production IDs
- Feature graphic for Play Store (1024x500)
- Screenshots for store listing (2+ required)
- Generate signed release build (.aab)
- Internal testing on Google Play Console

### Recent Improvements (December 2024)
1. **Physics Tuning:** 1.3x bounce, smoother merges with 90% velocity retention
2. **Shake Enhancement:** 2x stronger with rapid stacking (0.1s cooldown for max responsiveness)
3. **Fruit Sizing:** Dynamic scaling (1.4x for 7-8, 1.19x for 9-11)
4. **Collision Detection:** Auto-generated from sprite alpha with tight fitting
5. **Audio Balance:** 40% music volume, fruit-specific sounds only for #1 drops
6. **UX Improvements:** ESC key pause, no auto-tutorial, menu music everywhere
7. **Merge Speed:** Instant continuation with 0.15s animation (was 0.4s)
8. **UI Overhaul (December 31, 2024):**
   - Enlarged play area to 650x1100 for better gameplay space
   - Removed combo display for cleaner interface
   - Score now 64px (primary focus), High Score 32px, swapped positions
   - All Settings/Pause fonts increased for better readability
   - Settings screen now scrollable with Credits section
   - Credits: Bonsai logo (360x360) with hover effect, links to bonsaidotdot.com
   - Music credit: Jacob Lives Music link to jacoblivesmusic.com
   - Removed all emojis from UI (Android compatibility)
   - Pause button uses "| |" text instead of emoji
   - Tutorial uses plain text numbers instead of emoji numbers
   - App icon created using fruit 1 (BlueberrinniOctopussini)
   - Container corners rounded (20px radius) for polished look
   - Shake button repositioned lower to avoid Android overlap

9. **Critical Bug Fixes (December 31, 2024):**
   - Fixed fruits escaping container during shaking (velocity-based check)
   - Game over triggers when fruit LANDS outside bounds (velocity < 300 px/s)
   - Fruits can fly above red line and fall back in without game over
   - Tighter margins (80px sides, 100px bottom) for better control
   - Added smooth circular collision shapes at bottom corners (prevents stuck fruits)
   - Repositioned shake button to avoid overlap on all Android devices

10. **Critical Fix - High Score Persistence (January 1, 2025):**
   - **Root Cause:** SaveManager's `_ready()` was racing with ScoreManager's `_ready()`
   - ScoreManager would sometimes load before SaveManager loaded save data
   - This caused SaveManager.get_high_score() to return 0, overwriting the saved file
   - **Solution:** Moved data loading from `_ready()` to `_init()` in SaveManager
   - `_init()` runs immediately when singleton is created, before any `_ready()` calls
   - This guarantees SaveManager loads save data before other autoloads access it
   - High scores now persist correctly across app restarts ✅

### Performance Optimization
- Fruit pooling: Auto-returns on merge/removal
- Particle pooling: Auto-returns after effect
- Limit enforcement: Culls oldest when >75 fruits
- Use Godot Profiler: Target <16.67ms frame time

---

## Release Checklist (Milestone 7 - 95% COMPLETE)

**✅ Content Complete:**
- [x] Custom fruit sprites (11 unique animal-fruit hybrids)
- [x] Custom audio files (music + SFX)
- [x] In-game settings menu
- [x] Bonsai logo added to assets/sprites/ui/bonsai_logo.png
- [x] App icon created (icon.png using BlueberrinniOctopussini)
- [x] Privacy policy hosted at bonsaidotdot.com/legal/privacy.html

**✅ Store Setup Complete:**
- [x] AdMob account created and configured
- [x] Production App ID: ca-app-pub-2547513308278750~1856760076
- [x] Production Ad Unit ID: ca-app-pub-2547513308278750/3568656364
- [x] Google Play Console account created
- [x] Draft app listing created in Google Play Console
- [x] Store listing descriptions completed (short + full)

**⏳ Final Deployment (Remaining):**
- [ ] Switch AdManager.gd from USE_TEST_ADS=true to USE_TEST_ADS=false
- [ ] Create feature graphic (1024x500 PNG) for Play Store banner
- [ ] Take screenshots (minimum 2, portrait orientation: 1080x1920)
- [ ] Generate keystore for signing (if not already created)
- [ ] Configure export settings in Godot with keystore path
- [ ] Generate signed release build (.aab)
- [ ] Test production ads on release build
- [ ] Upload to Google Play Console (internal testing track)
- [ ] Submit for review and publish

**Store Listing:**
- App Name: Italian Brainrot Tutti Fruttini Combinasion
- Category: Puzzle | Rating: Everyone
- Pricing: Free with ads (rewarded only)
- Privacy Policy: https://bonsaidotdot.com/legal/privacy.html

---

## Quick Reference: Critical Files

| File | Purpose |
|------|---------|
| `AdManager.gd` | AdMob integration, test IDs, 30s fallback timer |
| `FruitPool.gd` | Object pooling (30→100 max, 75 active limit) |
| `ParticlePool.gd` | Particle system pooling (15 pre-warmed) |
| `SaveManager.gd` | JSON persistence, auto-save |
| `AudioManager.gd` | 15-channel SFX pool, music control |
| `Fruit.gd` | Merge logic, sprite-based collision generation, animations |
| `Main.gd` | Main game loop, pause system (ESC key), UI updates |
| `MainMenu.gd` | Main menu with optional quit button, manual tutorial |
| `Spawner.gd` | Input handling, mouse preview, spawn cooldown |
| `ShakeManager.gd` | Impulse system, camera shake, persistence |
| `GameOverDetector.gd` | Danger zone, grace period (2s), velocity filter |

---

## Privacy & Compliance

**COPPA:** Mark as "Not primarily for children" (ages 10+)
**GDPR:** Use AdMob consent SDK for EEA users

**Privacy Policy Requirements:**
- Disclose AdMob data collection (Ad ID, IP, device info)
- State no personal data collected by game
- Provide opt-out instructions (device settings)
- Link: https://bonsaidotdot.com/legal/privacy.html

---

**Last Updated:** December 31, 2024
**Contact:** bonsai@bonsaidotdot.com

*This is a living document. Update as development progresses.*

---

## Assets Needed

**Completed:**
- ✅ `icon.png` - App icon created using fruit 1 (BlueberrinniOctopussini)
- ✅ `assets/sprites/ui/bonsai_logo.png` - Developer logo (360x360)

**For Store Listing Only:**
- Feature graphic (1024x500 PNG) - Play Store banner
- Screenshots (2-8 images, 1080x1920) - Gameplay screenshots
