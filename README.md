# 🍉 Italian Brainrot Tutti Fruttini Combinasion

A physics-based fruit-merging puzzle game built with Godot 4.2+. Drop fruits, merge identical ones, and shake the pile to reach the ultimate watermelon!

**Status:** v1.0.0 Pre-Release (78% Complete)
**Platform:** Android (primary), iOS (future)
**Engine:** Godot 4.2+
**License:** Proprietary

---

## 📋 Table of Contents

- [Features](#-features)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Building & Running](#-building--running)
- [Architecture](#-architecture)
- [Documentation](#-documentation)
- [Current Status](#-current-status)
- [Contributing](#-contributing)

---

## ✨ Features

### Core Gameplay
- **11 Fruit Tiers:** Blueberry → Apple → Lemon → Coconut → Banana → Dragon Fruit → Orange → Grapes → Pineapple → Watermelon → Strawberry
- **Physics-Based Merging:** Realistic 2D physics with gravity, collisions, and soft bouncing
- **Combo System:** Score multipliers (1.0x - 3.0x) for chain merges
- **Shake Mechanic:** Limited-use physics impulse system (50 shakes max)
- **Game Over Grace Period:** 2-second countdown when fruits reach danger zone

### Monetization
- **Player-Friendly:** Rewarded ads only (no forced ads)
- **Shake Refills:** Watch ad to refill shake counter to 50
- **Fallback System:** Free refill after 30s if ad unavailable

### Menus & UI
- Main menu with high score display
- In-game pause menu
- Settings menu (audio, vibration controls)
- Tutorial screen (auto-shows on first launch)
- Game over screen with restart option

### Persistence
- High score tracking
- Shake count persistence
- Settings persistence (audio volumes, toggles)
- Game statistics (games played, total merges)

---

## 📁 Project Structure

```
tutti-fruttini/
│
├── .claude/                      # Claude Code project instructions
│   └── CLAUDE.md                 # Technical reference & specifications
│
├── scenes/                       # Godot scene files
│   ├── Main.tscn                 # Main gameplay scene
│   ├── Fruit.tscn                # Fruit prefab (RigidBody2D)
│   ├── MainMenu.tscn             # Entry point
│   ├── GameOver.tscn             # Game over overlay
│   ├── Pause.tscn                # Pause menu overlay
│   ├── Settings.tscn             # Settings menu overlay
│   └── Tutorial.tscn             # How to play screen
│
├── scripts/                      # GDScript source files
│   ├── autoload/                 # Singleton autoload scripts
│   │   ├── GameManager.gd        # Fruit data & game state
│   │   ├── ScoreManager.gd       # Scoring, combos, high scores
│   │   ├── AudioManager.gd       # Music & SFX (15-channel pool)
│   │   ├── SaveManager.gd        # JSON persistence system
│   │   └── AdManager.gd          # AdMob integration
│   │
│   ├── Main.gd                   # Main scene controller
│   ├── Fruit.gd                  # Fruit behavior & merge logic
│   ├── Spawner.gd                # Input handling & fruit spawning
│   ├── ShakeManager.gd           # Shake mechanic implementation
│   ├── GameOverDetector.gd       # Danger zone detection
│   ├── FruitPool.gd              # Object pooling (30→100 fruits)
│   ├── ParticlePool.gd           # Particle system pooling (15 systems)
│   ├── Utils.gd                  # Helper functions
│   ├── MainMenu.gd               # Main menu controller
│   ├── GameOver.gd               # Game over screen controller
│   ├── Pause.gd                  # Pause menu controller
│   ├── Settings.gd               # Settings menu controller
│   └── Tutorial.gd               # Tutorial screen controller
│
├── data/                         # Game data files
│   └── fruit_data.json           # 11 fruit definitions (size, score, spawn weight)
│
├── assets/                       # Game assets
│   └── sounds/                   # Audio files
│       ├── sfx/                  # Sound effects (7 files)
│       │   ├── merge_01-05.wav   # Merge sounds (randomized)
│       │   ├── drop.wav          # Fruit drop sound
│       │   ├── shake.wav         # Shake effect sound
│       │   ├── game_over.wav     # Game over sound
│       │   ├── click.wav         # UI button click
│       │   └── refill.wav        # Shake refill success
│       └── music/                # Background music
│           └── bgm_main.ogg      # Main gameplay loop
│
├── tests/                        # Testing documentation
│   └── TESTING_GUIDE.md          # Manual testing checklist
│
├── ADMOB_SETUP.md                # AdMob integration guide
├── ANDROID_BUILD_GUIDE.md        # Android build & deployment guide
├── ASSET_SOURCING_GUIDE.md       # Free asset resources
├── PERFORMANCE.md                # Performance optimization guide
├── SCENE_SETUP_GUIDE.md          # Scene creation guide
├── PRIVACY_POLICY.md             # Privacy policy (Markdown)
├── privacy_policy.html           # Privacy policy (HTML for hosting)
├── QUICK_STATUS.md               # Current completion status
├── REMAINING_TASKS.md            # Detailed task breakdown
│
├── project.godot                 # Godot project configuration
├── default_bus_layout.tres       # Audio bus configuration
├── icon.svg                      # Godot default icon
└── icon_placeholder.svg          # App icon placeholder (watermelon)
```

---

## 🚀 Getting Started

### Prerequisites

- **Godot Engine:** 4.2 or later ([Download](https://godotengine.org/download))
- **Git:** For version control
- **Android SDK:** Required for Android builds (see `ANDROID_BUILD_GUIDE.md`)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd tutti-fruttini
   ```

2. **Open in Godot:**
   - Launch Godot Engine
   - Click "Import"
   - Navigate to project folder
   - Select `project.godot`
   - Click "Import & Edit"

3. **Run the game:**
   - Press `F5` or click the "Play" button in Godot
   - Game will start at `scenes/MainMenu.tscn`

### First-Time Setup

The game will work out of the box with:
- ✅ Colored circle placeholders for fruits
- ✅ Silent audio (gracefully handled)
- ✅ Test AdMob IDs (safe for development)

**Optional:** Add custom assets (see `ASSET_SOURCING_GUIDE.md`)

---

## 🛠️ Building & Running

### Desktop (Development)

**Run in Editor:**
```bash
# From Godot editor
Press F5

# Or from command line
godot --path . --editor
```

**Export Desktop Build:**
- Project → Export
- Select platform (Windows, macOS, Linux)
- Export project

### Android

**Quick Start:**
Follow the comprehensive guide: `ANDROID_BUILD_GUIDE.md`

**Summary:**
1. Install Android SDK and build template
2. Configure export preset in Godot
3. Install AdMob plugin (optional, has fallback)
4. Build APK/AAB:
   ```bash
   godot --headless --export-release "Android" bin/tuttifruttini-release.aab
   ```

**AdMob Setup:**
See `ADMOB_SETUP.md` for production ad configuration

---

## 🏗️ Architecture

### Autoload Singletons (Global Access)

| Singleton | Purpose | Key Features |
|-----------|---------|--------------|
| `GameManager` | Fruit data & game state | Loads fruit_data.json, manages game flow |
| `ScoreManager` | Scoring system | Score, combo (1.0-3.0x), high score tracking |
| `AudioManager` | Audio system | 15-channel SFX pool, music control |
| `SaveManager` | Data persistence | JSON save/load (`user://save_data.json`) |
| `AdManager` | Ad integration | AdMob rewarded ads + 30s fallback timer |

### Scene Hierarchy (Main.tscn)

```
Main (Node2D)
├── Camera2D
│   └── (Camera shake effect)
│
├── Container (Node2D)
│   ├── LeftWall (StaticBody2D)
│   ├── RightWall (StaticBody2D)
│   └── Floor (StaticBody2D)
│
├── GameplayArea (Node2D)
│   ├── SpawnPoint (Marker2D)
│   ├── FruitContainer (Node2D)       # Fruits spawned here
│   ├── GameOverDetector (Area2D)     # Danger zone at top
│   └── NextFruitPreview (Sprite2D)   # Mouse-following preview
│
├── Managers (Node)
│   ├── Spawner                       # Input handling, spawning
│   └── ShakeManager                  # Shake mechanic
│
├── UI (CanvasLayer)
│   ├── ScoreLabel, HighScoreLabel
│   ├── ComboLabel                    # Color-coded multiplier
│   ├── ShakeButton                   # With counter display
│   └── RefillButton                  # Hidden until shakes = 0
│
├── FruitPool (Node2D)                # Object pool (30→100 max)
└── ParticlePool (Node2D)             # Particle systems (15)
```

### Object Pooling

**FruitPool:**
- Pre-instantiates 30 fruits
- Max pool size: 100 fruits
- Active limit: 75 fruits (auto-culls oldest)
- Fruits auto-return on merge/removal

**ParticlePool:**
- 15 pre-warmed particle systems
- Auto-returns after effect completion
- Prevents instantiation lag

### Data Flow

```
User Input → Spawner → FruitPool.get_fruit()
                          ↓
                    Fruit spawned
                          ↓
              Collision Detection (physics)
                          ↓
              MergeArea overlap detected
                          ↓
           Fruit.gd checks merge conditions
                          ↓
     ScoreManager.add_score() + combo
                          ↓
              ParticlePool.play_effect()
                          ↓
                 FruitPool.return_fruit()
```

### Physics Configuration

- **Gravity:** 980.0 (realistic)
- **Physics Ticks:** 60/second
- **Fruit Material:**
  - Friction: 0.5
  - Bounce: 0.09 (soft, minimal bouncing)
- **Merge Conditions:**
  - Identical fruit levels
  - Velocity < 300 px/s (average)
  - Merge cooldown: 0.05s

### Collision Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | Walls | StaticBody2D (container) |
| 2 | Fruits | RigidBody2D (all fruits) |
| 4 | MergeDetection | Area2D (merge zones) |
| 8 | GameOverZone | Area2D (top boundary) |

---

## 📚 Documentation

### Quick Reference
- **[QUICK_STATUS.md](QUICK_STATUS.md)** - Current completion status & next steps
- **[.claude/CLAUDE.md](.claude/CLAUDE.md)** - Technical reference & specifications

### Guides
- **[ANDROID_BUILD_GUIDE.md](ANDROID_BUILD_GUIDE.md)** - Android setup & deployment
- **[ADMOB_SETUP.md](ADMOB_SETUP.md)** - AdMob integration (test/production)
- **[ASSET_SOURCING_GUIDE.md](ASSET_SOURCING_GUIDE.md)** - Free asset resources
- **[SCENE_SETUP_GUIDE.md](SCENE_SETUP_GUIDE.md)** - Scene structure details
- **[PERFORMANCE.md](PERFORMANCE.md)** - Optimization guide

### Testing
- **[tests/TESTING_GUIDE.md](tests/TESTING_GUIDE.md)** - Manual testing checklist

### Tasks & Planning
- **[REMAINING_TASKS.md](REMAINING_TASKS.md)** - Detailed task breakdown
- **[GAME_COMPLETION_TODO.md](GAME_COMPLETION_TODO.md)** - Completion roadmap

### Legal
- **[PRIVACY_POLICY.md](PRIVACY_POLICY.md)** - Privacy policy (GDPR/COPPA/CCPA compliant)

---

## 📊 Current Status

**Version:** 1.0.0 Pre-Release
**Completion:** ~78%

### ✅ Complete (Milestones 1-6)
- Core gameplay (drop, merge, shake, game over)
- All menus & UI (main, pause, settings, tutorial, game over)
- AdMob integration with fallback
- Save/load system
- Audio system (15-channel pool)
- Object pooling (fruits, particles)
- Complete documentation

### ⏳ In Progress (Milestone 7)
- Game assets (sprites, sounds) - **using placeholders**
- Android build setup - **not started**
- Google Play Store listing - **not started**

### 🎯 Next Steps
1. **Option A (Quick Launch):** Generate basic sounds, follow Android build guide → launch in 2 days
2. **Option B (Polished):** Source free assets, integrate, test → launch in 1 week

See **[QUICK_STATUS.md](QUICK_STATUS.md)** for detailed breakdown.

---

## 🧪 Testing

### Run Unit Tests
*Unit testing framework not yet implemented*

### Manual Testing
Follow checklist in **[tests/TESTING_GUIDE.md](tests/TESTING_GUIDE.md)**

### Performance Testing
- Use Godot Profiler (Debug → Profiler)
- Target: <16.67ms frame time (60 FPS)
- Monitor physics time: <8ms
- Check memory: <150MB
- See **[PERFORMANCE.md](PERFORMANCE.md)** for detailed guide

---

## 🤝 Contributing

This is a proprietary project by **Bonsai...**

For development questions or bug reports, contact: **bonsai@bonsaidotdot.com**

---

## 📝 Save Data Location

**Path:** `user://save_data.json`

**Platform-specific locations:**
- **Windows:** `%APPDATA%\Godot\app_userdata\Tutti Fruttini\`
- **macOS:** `~/Library/Application Support/Godot/app_userdata/Tutti Fruttini/`
- **Linux:** `~/.local/share/godot/app_userdata/Tutti Fruttini/`
- **Android:** `/data/data/com.bonsaidotdot.tuttifruttini/files/`

**Structure:**
```json
{
  "version": "1.0.0",
  "high_score": 0,
  "shake_count": 50,
  "settings": {
    "music_volume": 0.8,
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

---

## 🔧 Troubleshooting

### Game won't start
- Check Godot version (4.2+)
- Verify project.godot exists
- Check console for errors

### Audio not working
- Audio files are placeholders - game handles gracefully
- Check Settings menu → ensure audio enabled
- See ASSET_SOURCING_GUIDE.md for free sounds

### AdMob ads not showing
- Using test IDs by default (expected in development)
- For production: see ADMOB_SETUP.md
- Fallback: Free refill after 30s if ad unavailable

### Android build fails
- Follow ANDROID_BUILD_GUIDE.md step-by-step
- Ensure Android SDK installed
- Check export preset configuration

---

## 📞 Contact & Support

**Developer:** Bonsai...
**Email:** bonsai@bonsaidotdot.com
**Privacy Policy:** https://bonsaidotdot.com/legal/privacy.html

---

## 🎮 Gameplay Quick Start

1. **Tap/Click** to drop fruits
2. **Identical fruits merge** when they collide
3. **Shake button** (bottom-right) jostles the pile
4. **Avoid overflow** - fruits at top for 2s = game over
5. **Build combos** - merge quickly for score multipliers!

**Goal:** Merge your way to the legendary Watermelon! 🍉

---

**Last Updated:** December 2024
**Status:** Ready for asset integration and Android build setup

*Happy merging! 🍒🍓🍇🍊🍋🍎🍐🍑🍍🍈🍉*
