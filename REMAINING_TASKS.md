# Remaining Tasks - Tutti Fruttini

**Current Completion: ~78%**
**Last Updated**: December 27, 2024

This document summarizes ALL remaining tasks to complete the game for 1.0 release.

---

## 🚨 CRITICAL - Cannot Release Without These

### 1. Fruit Sprites (11 Total) 🎨

**Current Status**: Using colored circles (placeholder)
**Required**: Italian brainrot themed fruit sprites

**Needed**:
- [ ] Cherry (Level 0) - 72x72px (36px radius × 2)
- [ ] Strawberry (Level 1) - 84x84px (42px radius × 2)
- [ ] Grape (Level 2) - 100x100px (50px radius × 2)
- [ ] Orange (Level 3) - 134x134px (67px radius × 2)
- [ ] Lemon (Level 4) - 168x168px (84px radius × 2)
- [ ] Apple (Level 5) - 202x202px (101px radius × 2)
- [ ] Pear (Level 6) - 236x236px (118px radius × 2)
- [ ] Peach (Level 7) - 268x268px (134px radius × 2)
- [ ] Pineapple (Level 8) - 302x302px (151px radius × 2)
- [ ] Melon (Level 9) - 336x336px (168px radius × 2)
- [ ] Watermelon (Level 10) - 416x416px (208px radius × 2)

**Requirements**:
- Format: PNG with transparency
- Style: Cute, cartoony, consistent art style
- Italian brainrot theme (quirky, fun aesthetic)
- All fruits should look cohesive

**Options**:
1. **Commission Artist**: $50-200 for all 11 sprites
2. **Create Yourself**: Use Aseprite, GIMP, Photoshop, or Procreate
3. **Use AI**: Generate with Midjourney/DALL-E and touch up
4. **Asset Stores**: Search itch.io, OpenGameArt.org for free/paid fruit sprites
5. **Placeholder**: Ship with circles (NOT recommended for release)

**Time Estimate**: 4-10 hours (DIY) or 1-2 weeks (commission)

---

### 2. Audio Files (7 Total) 🔊

**Current Status**: Silent (gracefully handles missing files)
**Required**: Sound effects and background music

**Sound Effects Needed** (`.wav` format):

- [ ] **merge_01.wav** - Merge sound variant 1
- [ ] **merge_02.wav** - Merge sound variant 2
- [ ] **merge_03.wav** - Merge sound variant 3
- [ ] **merge_04.wav** - Merge sound variant 4
- [ ] **merge_05.wav** - Merge sound variant 5
  - Description: Short, satisfying "pop" or "bloop" sounds
  - Duration: 0.2-0.5 seconds
  - Style: Playful, bubbly

- [ ] **drop.wav**
  - Description: Fruit drop sound
  - Duration: 0.1-0.3 seconds
  - Style: Soft "plop" or "thud"

- [ ] **shake.wav**
  - Description: Shake mechanic sound
  - Duration: 0.3-0.5 seconds
  - Style: Rumble/rattle effect

- [ ] **game_over.wav**
  - Description: Game over sound
  - Duration: 1.0-2.0 seconds
  - Style: Descending tone, gentle (not harsh)

- [ ] **click.wav**
  - Description: UI button click
  - Duration: 0.05-0.1 seconds
  - Style: Crisp, clean click

- [ ] **refill.wav**
  - Description: Shake refill success
  - Duration: 0.5-1.0 seconds
  - Style: Positive, rewarding chime

**Music Needed** (`.ogg` format):

- [ ] **bgm_main.ogg**
  - Description: Main gameplay background music
  - Duration: 1-2 minutes (seamlessly looping)
  - Style: Upbeat, casual, Italian/Mediterranean vibe
  - Tempo: Medium, non-intrusive

**Requirements**:
- **SFX**: 44.1kHz, 16-bit, WAV format
- **Music**: OGG Vorbis format (for looping)
- All sounds should blend well together
- Not harsh or jarring

**Options**:
1. **Create with Tools**: BFXR, ChipTone, Audacity (free)
2. **Free Sources**: Freesound.org, OpenGameArt.org, Incompetech (music)
3. **Purchase**: Itch.io, Unity Asset Store ($5-50)
4. **Commission**: Audio designer ($50-200)
5. **AI Generate**: ElevenLabs, Soundraw (for music)

**Time Estimate**: 2-6 hours (sourcing) or 1-2 weeks (custom creation)

---

### 3. App Icon 📱 ✅ PLACEHOLDER COMPLETE

**Current Status**: ✅ Placeholder watermelon icon created (icon_placeholder.svg)
**Required**: Custom Tutti Fruttini icon

**Specifications**:
- **Size**: 1024x1024px (source)
- **Format**: PNG
- **Content**: Fruit/watermelon themed, game branding
- **Adaptive Icon** (optional): Separate foreground/background layers

**Needed**:
- [x] Main app icon placeholder (1024x1024 SVG created)
- [ ] Export to PNG or create final custom icon (optional improvement)
- [ ] Adaptive icon foreground (432x432) - optional
- [ ] Adaptive icon background (432x432) - optional

**Options**:
1. Simple: Large watermelon emoji 🍉 on colored background
2. Custom: Design with fruit stack or game logo
3. Professional: Commission icon designer ($20-100)

**Time Estimate**: 30 minutes - 2 hours

---

### 4. Android Build Setup ⚙️

**Current Status**: Guide created, setup not done
**Required**: Configure Godot for Android export

**See ANDROID_BUILD_GUIDE.md for details**.

**Tasks**:
- [ ] Install Android build template
- [ ] Configure Android SDK in Godot
- [ ] Create Android export preset
- [ ] Edit AndroidManifest.xml (add AdMob ID)
- [ ] Install AdMob plugin
- [ ] Set `USE_TEST_ADS = false` in AdManager.gd
- [ ] Create release keystore
- [ ] Configure keystore in export preset
- [ ] Build test APK
- [ ] Test on device

**Time Estimate**: 2-4 hours

---

### 5. Privacy Policy 📄 ✅ COMPLETE

**Current Status**: ✅ Created and hosted on web server
**Required**: Google Play requires privacy policy for apps with ads

**What's Needed**:
- [x] Privacy policy document (PRIVACY_POLICY.md created)
- [x] Host online (privacy_policy.html uploaded to bonsaidotdot.com)
- [ ] Add URL to Play Store listing (when creating listing)

**Minimum Template**:
```
Privacy Policy for Tutti Fruttini

This app uses Google AdMob to display advertisements.

Data Collected by AdMob:
- Advertising ID
- Device information
- IP address
- App usage data

This data is used solely for serving relevant advertisements.
We do not collect, store, or share any personal information directly.

To opt out of personalized ads:
Android: Settings → Google → Ads → Opt out of Ads Personalization

For more information:
Google Privacy Policy: https://policies.google.com/privacy
AdMob Privacy: https://support.google.com/admob/answer/6128543

Contact: [your-email@example.com]
Last Updated: [date]
```

**Hosting Options**:
1. **GitHub Pages** (free): Create repo, add `privacy.html`
2. **Your Website**: If you have one
3. **Google Sites** (free): Create simple site
4. **Termly.io** (free tier): Auto-generate privacy policy

**Time Estimate**: 30 minutes - 1 hour

---

## ⭐ HIGH PRIORITY - Strongly Recommended

### 6. Tutorial / How to Play Screen ✅ COMPLETE

**Current Status**: ✅ Implemented and integrated
**Why Important**: New players won't know how to play

**What's Needed**:
- [x] First-time tutorial overlay (shows on first launch)
- [x] Explains:
  - Tap to drop fruit
  - Identical fruits merge
  - Don't let fruits reach the top
  - Shake mechanic (limited uses)
  - Goal: Get watermelon
- [x] Auto-dismisses after first view (saved in SaveManager)
- [x] "How to Play" button in main menu

**Options**:
1. **Simple**: Text overlay with instructions
2. **Better**: Animated arrows showing tap/merge
3. **Best**: Interactive tutorial (play through first merge)

**Time Estimate**: 2-4 hours

---

### 7. Balance Testing & Fine-Tuning

**Current Status**: Core mechanics work, not extensively tested
**Why Important**: Game could be too easy/hard/frustrating

**Testing Needed**:
- [ ] Play 10+ complete games yourself
- [ ] Track average game duration
- [ ] Track average score
- [ ] Note difficulty pain points
- [ ] Test spawn rates (are right fruits spawning?)
- [ ] Test merge frequency (do fruits merge easily enough?)
- [ ] Test shake usefulness (50 shakes enough? too many?)

**Adjustments to Consider**:

**If Too Hard**:
- Increase grace period (currently 2 seconds)
- Increase shake count (currently 50)
- Adjust spawn weights (spawn easier fruits more)
- Increase container size slightly

**If Too Easy**:
- Decrease grace period
- Decrease shake count
- Spawn harder fruits more frequently
- Decrease container size slightly

**Physics Tuning**:
- Bounce (currently 0.09) - higher = more bouncy
- Friction (currently 0.5) - higher = less sliding
- Fruit sizes (currently 0.85x scale) - adjust if cramped/spacious

**Time Estimate**: 3-6 hours

---

### 8. External Playtesting

**Current Status**: Only you have tested
**Why Important**: Fresh eyes find issues you won't see

**What's Needed**:
- [ ] 5+ external testers (friends, family)
- [ ] Provide test build (APK)
- [ ] Collect feedback:
  - Was tutorial clear?
  - Difficulty level (too easy/hard?)
  - Frustration points?
  - Bugs encountered?
  - Suggestions?

**Time Estimate**: 1-2 weeks (waiting for feedback)

---

### 9. Device Testing

**Current Status**: Tested in Godot editor only (probably)
**Why Important**: Ensure works on all Android devices

**Test Devices Needed**:
- [ ] **Low-End**: Android 7-9, 2GB RAM
  - Target: 45+ FPS
  - Test: Load time, performance with 50+ fruits

- [ ] **Mid-Range**: Android 10-12, 4GB RAM
  - Target: 60 FPS
  - Test: All features work smoothly

- [ ] **High-End**: Android 13+, 8GB+ RAM
  - Target: Locked 60 FPS
  - Test: No issues

**Screen Sizes**:
- [ ] 16:9 aspect ratio
- [ ] 18:9 aspect ratio
- [ ] 19.5:9 aspect ratio (with notch)
- [ ] 20:9 aspect ratio

**Time Estimate**: 4-8 hours

---

## 🎯 MEDIUM PRIORITY - Nice to Have

### 10. Additional Visual Polish

**Current Status**: Basic UI, functional but plain
**Optional Improvements**:

- [ ] **UI Animations**:
  - Button hover/press effects
  - Panel slide-in animations
  - Score pop-up effects
  - Combo multiplier pulse

- [ ] **Screen Transitions**:
  - Fade between scenes
  - Smooth scene changes
  - Loading transitions

- [ ] **Visual Effects**:
  - More varied particle effects
  - Screen flash on combo
  - Fruit squash/stretch on impact
  - Glow effects for high combos

**Time Estimate**: 4-8 hours

---

### 11. Better UI Graphics

**Current Status**: Default Godot buttons/panels
**Optional Improvements**:

- [ ] Custom button sprites (rounded, stylized)
- [ ] Custom panel backgrounds
- [ ] Decorative UI elements
- [ ] Better fonts (custom font file)
- [ ] Icons instead of emoji (🔔 → custom bell icon)

**Time Estimate**: 3-6 hours

---

### 12. Container & Background Visuals

**Current Status**: Solid color background, simple walls
**Optional Improvements**:

- [ ] Textured container walls
- [ ] Patterned floor
- [ ] Background scene (Italian landscape, kitchen, etc.)
- [ ] Container decorations

**Time Estimate**: 2-4 hours

---

### 13. Credits Screen

**Current Status**: No credits
**Optional Addition**:

- [ ] Credits scene showing:
  - Developer name
  - Asset credits (art, audio)
  - Plugin credits (AdMob, Godot)
  - Special thanks
- [ ] Credits button in main menu

**Time Estimate**: 1 hour

---

### 14. Menu Background Music

**Current Status**: Only gameplay music planned
**Optional Addition**:

- [ ] Separate music for main menu
- [ ] Different from gameplay music
- [ ] Calmer, more ambient

**Time Estimate**: 1-2 hours (sourcing/creating)

---

## 🚀 MILESTONE 7 - Release Preparation

**After all critical tasks complete**:

### 15. Google Play Console Setup

- [ ] Create developer account ($25 one-time fee)
- [ ] Create app listing
- [ ] Fill out store listing details
- [ ] Add privacy policy URL
- [ ] Set up content rating questionnaire
- [ ] Configure pricing (Free)
- [ ] Select countries/regions

**Time Estimate**: 2-4 hours

---

### 16. Store Listing Assets

**Required by Play Store**:

- [ ] **Screenshots** (5+ required):
  - Main menu
  - Gameplay
  - Merge happening
  - High score
  - Game over screen
  - All must be 1080x1920 (portrait)

- [ ] **Feature Graphic** (1024x500):
  - Banner for Play Store
  - Game logo + key art

- [ ] **App Description**:
  - Short description (80 chars)
  - Full description (4000 chars max)
  - See marketing copy below

- [ ] **Promotional Graphics** (optional):
  - Promo video
  - Promotional graphic (180x120)

**Time Estimate**: 2-4 hours

---

### 17. Marketing Copy

**Short Description** (80 chars max):
```
Merge fruits in this addictive physics puzzle! 🍉
```

**Full Description**:
```
🍒 Drop fruits into the container
🍓 Merge identical fruits to create bigger ones
🍊 Shake the pile when you get stuck
🍉 Reach the legendary watermelon!

Italian Brainrot Tutti Fruttini Combinasion is the most satisfying
fruit-merging puzzle game! Use realistic physics to drop and stack
fruits, then watch as identical fruits magically merge into larger ones.

FEATURES:
✨ Smooth, realistic physics
✨ 11 unique fruit types
✨ Shake mechanic to jostle the pile
✨ No forced ads - only optional reward ads
✨ Minimalist, beautiful design
✨ Satisfying merge effects

Perfect for quick gaming sessions or long puzzle marathons!

Download now and start merging! 🎮
```

---

### 18. Final QA Testing

**Before Release**:

- [ ] Full playthrough (no bugs)
- [ ] All menus work
- [ ] Settings persist
- [ ] Ads work correctly (production mode)
- [ ] Pause works
- [ ] Game over triggers correctly
- [ ] Restart works
- [ ] High score saves
- [ ] Audio plays correctly
- [ ] No crashes
- [ ] Performance acceptable on all devices

**Time Estimate**: 2-4 hours

---

### 19. Upload & Release

- [ ] Build signed release AAB
- [ ] Upload to Play Console
- [ ] Internal testing (optional but recommended)
- [ ] Alpha/Beta testing (optional)
- [ ] Production release
- [ ] Monitor for crashes/issues

**Time Estimate**: 2-4 hours

---

## 📊 Summary by Priority

### CRITICAL (Cannot Release Without) ⛔
1. ✅ Fruit sprites (11) - **4-10 hours**
2. ✅ Audio files (7) - **2-6 hours**
3. ✅ App icon - **30 min - 2 hours**
4. ✅ Android setup - **2-4 hours**
5. ✅ Privacy policy - **30 min - 1 hour**

**Critical Total**: 9-23 hours

---

### HIGH PRIORITY (Strongly Recommended) ⭐
6. Tutorial/How to Play - **2-4 hours**
7. Balance testing - **3-6 hours**
8. External playtesting - **1-2 weeks**
9. Device testing - **4-8 hours**

**High Priority Total**: 9-18 hours + 1-2 weeks

---

### MEDIUM PRIORITY (Nice to Have) 💫
10. Visual polish - **4-8 hours**
11. Better UI graphics - **3-6 hours**
12. Container visuals - **2-4 hours**
13. Credits screen - **1 hour**
14. Menu music - **1-2 hours**

**Medium Priority Total**: 11-21 hours

---

### RELEASE TASKS (Milestone 7) 🚀
15. Play Console setup - **2-4 hours**
16. Store listing assets - **2-4 hours**
17. Marketing copy - **included above**
18. Final QA - **2-4 hours**
19. Upload & release - **2-4 hours**

**Release Total**: 8-16 hours

---

## ⏱️ Total Time Estimates

**Minimum (Critical Only)**:
- 9-23 hours of work
- Can release with placeholders

**Recommended (Critical + High)**:
- 18-41 hours of work
- + 1-2 weeks for external testing
- Better quality release

**Polished (All Priorities)**:
- 38-78 hours of work
- + 1-2 weeks for testing
- Professional quality release

---

## 🎯 Fastest Path to Release

**If you want to release ASAP**:

1. **Week 1**: Get critical assets
   - Commission or create fruit sprites (4-10 hours)
   - Source or create audio files (2-6 hours)
   - Create app icon (30 min - 2 hours)

2. **Week 2**: Android & testing
   - Android setup (2-4 hours)
   - Build test APK
   - Balance testing (3-6 hours)
   - Fix issues found

3. **Week 3**: Release prep
   - Privacy policy (30 min - 1 hour)
   - Play Console setup (2-4 hours)
   - Screenshots & store listing (2-4 hours)
   - Final QA (2-4 hours)
   - Release!

**Timeline**: 3-4 weeks to release

---

## 📋 Current Status Breakdown

**What's Done** ✅:
- Core gameplay (100%)
- Shake mechanic (100%)
- AdMob integration (100%)
- Audio system (100% - just needs files)
- Save system (100%)
- Settings menu (100%)
- Pause menu (100%)
- Object pooling (100%)
- Performance optimization (100%)

**What's Missing** ⏳:
- Fruit sprites (0%)
- Audio files (0%)
- App icon (0%)
- Android setup (0% - guide ready)
- Privacy policy (0%)
- Tutorial (0%)
- Balance testing (20% - basic testing done)
- Play Store setup (0%)

**Overall Completion**: ~70%

---

## 🎮 Recommended Next Steps

**Option A: Full Polish**
1. Create/commission fruit sprites
2. Create/source audio files
3. Do balance testing
4. Create tutorial
5. Android setup
6. Release

**Option B: Quick Release**
1. Use simplified sprites (emoji-based or simple shapes)
2. Use free audio from asset stores
3. Basic balance testing
4. Android setup
5. Release v1.0
6. Update with better assets in v1.1

**Option C: Staged Approach**
1. Get fruit sprites done
2. Android setup and test build
3. External playtesting with test build
4. Add audio and polish based on feedback
5. Release

---

## 💰 Budget Estimates (If Outsourcing)

**Art**:
- Fruit sprites (11): $50-200
- App icon: $20-100
- UI graphics: $50-150
**Total Art**: $120-450

**Audio**:
- Sound effects (6): $30-100
- Background music: $20-100
**Total Audio**: $50-200

**Grand Total**: $170-650 if commissioning all assets

**DIY**: $0 but requires 15-30 hours for asset creation

---

## ✅ Quick Action Items (Next 3 Steps)

**If starting now, do these first**:

1. **Source fruit sprites**
   - Search free assets first
   - If not found, commission or create

2. **Source audio files**
   - Check freesound.org
   - Use BFXR for SFX if needed
   - Find royalty-free music

3. **Create app icon**
   - Simple watermelon design
   - 1024x1024 PNG

**Then**: Move to Android setup once assets are in

---

**Need help with any of these tasks?** I can:
- Help find free assets
- Guide you through Android setup
- Write privacy policy
- Create tutorial system
- Help with balance adjustments
- Write Play Store descriptions
