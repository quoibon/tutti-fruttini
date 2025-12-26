# Android Build Guide - Tutti Fruttini

This guide covers all steps needed to prepare the game for Android and build the APK/AAB.

**Current Status**: Development build ready
**Target**: Production-ready Android APK/AAB

---

## Prerequisites Checklist

### Required Software
- [ ] **Godot 4.5** installed
- [ ] **Android SDK** installed (via Android Studio or command-line tools)
- [ ] **Java JDK 17** installed
- [ ] **AdMob Plugin** installed (see ADMOB_SETUP.md)

### Required Accounts
- [ ] **Google Play Console** account (for publishing)
- [ ] **AdMob account** setup with app registered

---

## Step-by-Step Android Setup

### 1. Install Android Build Template

**In Godot Editor**:
1. Go to **Project → Install Android Build Template**
2. Click "Install"
3. This creates `android/build/` folder with:
   - `AndroidManifest.xml`
   - `build.gradle`
   - Other Android build files

**Verify**:
- [ ] `android/build/` folder exists
- [ ] `android/build/AndroidManifest.xml` exists

---

### 2. Configure Android SDK in Godot

**Editor → Editor Settings → Export → Android**:

1. **Android SDK Path**:
   - Windows: `C:\Users\[YourName]\AppData\Local\Android\Sdk`
   - Mac: `~/Library/Android/sdk`
   - Linux: `~/Android/Sdk`

2. **Debug Keystore**:
   - Auto-generated at: `~/.android/debug.keystore`
   - Used for debug builds only

3. **JDK Path** (if needed):
   - Should auto-detect Java 17
   - Manual: Point to JDK installation folder

**Verify**:
- [ ] SDK path is valid (green checkmark in Godot)
- [ ] Debug keystore detected

---

### 3. Create Android Export Preset

**Project → Export → Add → Android**:

#### Basic Settings
- **Name**: "Android"
- **Runnable**: ✅ Checked
- **Export With Debug**: ❌ Unchecked (for release)

#### Options → Application

**Package**:
- **Unique Name**: `com.bonsaidotdot.tuttifruitini`
- **Name**: `Tutti Fruttini`
- **Version Name**: `1.0.0`
- **Version Code**: `1` (increment for each release)
- **Min SDK**: `24` (Android 7.0)
- **Target SDK**: `34` (Android 14)

**Launcher Icons** (REQUIRED):
- [ ] Main Icon (432x432): `res://icon.png` or custom
- [ ] Adaptive Icon Foreground (432x432): Optional
- [ ] Adaptive Icon Background (432x432): Optional

**Screen**:
- **Orientation**: `Portrait` (locked)
- **Support Small**: ✅
- **Support Normal**: ✅
- **Support Large**: ✅
- **Support XLarge**: ✅

#### Options → Permissions

**Required Permissions**:
- [x] `INTERNET` (for AdMob)
- [x] `ACCESS_NETWORK_STATE` (for AdMob)
- [x] `VIBRATE` (for haptic feedback)

**DO NOT enable**:
- [ ] Location permissions (not needed)
- [ ] Camera/Microphone (not needed)
- [ ] Storage (not needed)

#### Options → Architectures

**Target Architectures** (check both):
- [x] `armeabi-v7a` (32-bit ARM)
- [x] `arm64-v8a` (64-bit ARM - REQUIRED by Play Store)

**DO NOT check** (unless needed):
- [ ] `x86` (Intel, rarely needed)
- [ ] `x86_64` (Intel 64-bit, rarely needed)

#### Options → Gradle Build

- **Use Gradle Build**: ✅ Checked
- **Gradle Build Dir**: `res://android/build`
- **Min SDK**: 24
- **Target SDK**: 34

---

### 4. Configure AndroidManifest.xml

**Location**: `android/build/AndroidManifest.xml`

**Required Additions**:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.bonsaidotdot.tuttifruitini"
    android:versionCode="1"
    android:versionName="1.0.0"
    android:installLocation="auto">

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.VIBRATE"/>

    <!-- Declare app is for handheld devices -->
    <uses-feature android:name="android.hardware.touchscreen" android:required="false"/>
    <uses-feature android:name="android.hardware.screen.portrait"/>

    <application
        android:label="Tutti Fruttini"
        android:icon="@mipmap/icon"
        android:allowBackup="true"
        android:isGame="true"
        android:hasFragileUserData="false"
        android:theme="@android:style/Theme.NoTitleBar.Fullscreen">

        <!-- AdMob App ID (PRODUCTION) -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-2547513308278750~1856760076"/>

        <!-- Main Activity -->
        <activity
            android:name="com.godotengine.godot.GodotApp"
            android:theme="@style/GodotAppSplashTheme"
            android:exported="true"
            android:screenOrientation="portrait"
            android:configChanges="orientation|keyboardHidden|screenSize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

**Key Points**:
- ✅ Package name matches export preset
- ✅ AdMob App ID is production ID (not test)
- ✅ Screen orientation locked to portrait
- ✅ isGame="true" (tells Play Store it's a game)

---

### 5. Install AdMob Plugin

**See ADMOB_SETUP.md for detailed instructions**.

**Quick Steps**:
1. Download plugin from: https://github.com/Poing-Studios/godot-admob-plugin
2. Extract to `res://addons/admob/`
3. Enable in **Project → Project Settings → Plugins**
4. Restart Godot

**Verify**:
- [ ] `addons/admob/` folder exists
- [ ] Plugin enabled in Godot
- [ ] AdManager.gd detects plugin (check console on run)

---

### 6. Set AdMob to Production Mode

**In `scripts/autoload/AdManager.gd`**:

**Change this**:
```gdscript
const USE_TEST_ADS: bool = true  // CHANGE THIS!
```

**To this**:
```gdscript
const USE_TEST_ADS: bool = false  // Production mode
```

**Verify**:
- [ ] `USE_TEST_ADS = false` in AdManager.gd
- [ ] AndroidManifest.xml has production App ID
- [ ] AdMob account has app approved and ads enabled

---

### 7. Create App Icon

**Requirements**:
- **Size**: 432x432 pixels minimum (1024x1024 recommended)
- **Format**: PNG with transparency OR solid background
- **Content**: Should represent the game (fruit/watermelon themed)

**Options**:

**A. Simple Approach** (Quick):
1. Create a 1024x1024 PNG with watermelon emoji 🍉
2. Save as `res://icon.png`
3. Godot will auto-resize for Android

**B. Proper Approach** (Better):
1. Design custom app icon (1024x1024)
2. Create adaptive icon layers:
   - Foreground: Main icon (432x432 with transparency)
   - Background: Solid color or pattern (432x432)
3. Set in export preset

**Current Status**:
- Default: `res://icon.svg` (Godot logo)
- **Action**: Replace with Tutti Fruttini icon

**Checklist**:
- [ ] Custom icon created
- [ ] Icon set in export preset
- [ ] Icon looks good at small sizes (test on device)

---

### 8. Create Release Keystore

**For production builds, you MUST create a release keystore**.

**Generate Keystore** (run in terminal):
```bash
keytool -genkey -v -keystore tutti-fruitini-release.keystore -alias tuttifruitini -keyalg RSA -keysize 2048 -validity 10000
```

**Answer Prompts**:
- Password: [CREATE STRONG PASSWORD]
- First/Last Name: Your name or company
- Organization: Bonsai (or your org)
- City, State, Country: Your location

**IMPORTANT**:
- ⚠️ **BACKUP THIS FILE SAFELY** - You cannot update your app without it!
- ⚠️ **SAVE THE PASSWORD** - You'll need it for every release
- ⚠️ Store in secure location (NOT in git repository)

**Location**:
- Save keystore file outside project (e.g., `~/keystores/tutti-fruitini-release.keystore`)

---

### 9. Configure Export Preset for Signing

**Project → Export → Android → Resources → Keystore**:

**Release Keystore**:
- **Release**: Path to `tutti-fruitini-release.keystore`
- **Release User**: `tuttifruitini` (the alias you created)
- **Release Password**: [Your keystore password]

**Debug Keystore** (leave default):
- Auto-uses `~/.android/debug.keystore`

**Verify**:
- [ ] Release keystore configured
- [ ] Password saved (you'll need it for every build)
- [ ] Keystore file backed up safely

---

### 10. Pre-Build Checklist

**Code & Assets**:
- [ ] All critical features complete
- [ ] Fruit sprites added (or placeholders acceptable)
- [ ] Audio files added (or graceful failure working)
- [ ] Settings menu tested
- [ ] Pause menu tested
- [ ] AdMob test ads working (then switch to production)

**Android Configuration**:
- [ ] Android build template installed
- [ ] Export preset created
- [ ] Package name set: `com.bonsaidotdot.tuttifruitini`
- [ ] Version code: 1
- [ ] Version name: 1.0.0
- [ ] Min SDK: 24
- [ ] Target SDK: 34
- [ ] Architectures: arm64-v8a + armeabi-v7a
- [ ] Permissions: INTERNET, ACCESS_NETWORK_STATE, VIBRATE
- [ ] Screen orientation: Portrait
- [ ] AndroidManifest.xml configured
- [ ] AdMob App ID in manifest (production)
- [ ] App icon created and set
- [ ] Release keystore created and configured

**AdMob**:
- [ ] Plugin installed and enabled
- [ ] `USE_TEST_ADS = false` in AdManager.gd
- [ ] AdMob account has app approved
- [ ] Rewarded ad unit created in AdMob dashboard

**Testing**:
- [ ] Tested in Godot editor (F5)
- [ ] All features working
- [ ] No critical bugs

---

## Building the APK/AAB

### Debug Build (Testing)

**For testing on your device**:

1. **Project → Export**
2. Select "Android" preset
3. Check "Export With Debug"
4. Click "Export Project"
5. Save as: `tutti-fruitini-debug.apk`

**Install on Device**:
```bash
adb install tutti-fruitini-debug.apk
```

**Test on Device**:
- [ ] Game launches
- [ ] Graphics render correctly
- [ ] Touch input works
- [ ] Audio plays (if files exist)
- [ ] Pause/Settings menus work
- [ ] Shake mechanic works
- [ ] Ads load (test mode first!)
- [ ] No crashes

---

### Release Build (Production)

**For uploading to Play Store**:

1. **VERIFY**:
   - [ ] `USE_TEST_ADS = false` in AdManager.gd
   - [ ] AndroidManifest has production AdMob ID
   - [ ] All content ready (or acceptable placeholders)

2. **Project → Export**
3. Select "Android" preset
4. **UNCHECK** "Export With Debug"
5. Select "Export AAB" (Android App Bundle - recommended)
6. Click "Export Project"
7. Save as: `tutti-fruitini-release.aab`

**Build Output**:
- `tutti-fruitini-release.aab` (for Play Store upload)
- OR `tutti-fruitini-release.apk` (for manual install)

**Verify Build**:
- [ ] File size reasonable (<50MB ideally)
- [ ] Signed with release keystore
- [ ] No debug symbols included

---

### Test Release Build

**Install AAB** (requires bundletool):
```bash
# Convert AAB to APK for testing
bundletool build-apks --bundle=tutti-fruitini-release.aab --output=tutti-fruitini.apks

# Install on device
bundletool install-apks --apks=tutti-fruitini.apks
```

**Or install APK directly**:
```bash
adb install tutti-fruitini-release.apk
```

**Critical Tests**:
- [ ] App launches
- [ ] Production ads load (shows real ads, not test ads)
- [ ] Ads reward shakes correctly
- [ ] All features work
- [ ] No crashes
- [ ] Performance acceptable (45+ FPS)

---

## Common Issues & Solutions

### Issue: "SDK not configured"
**Solution**: Set Android SDK path in Editor Settings → Export → Android

### Issue: "Build template not installed"
**Solution**: Project → Install Android Build Template

### Issue: "Plugin not found"
**Solution**:
1. Check `addons/admob/` exists
2. Enable in Project Settings → Plugins
3. Restart Godot

### Issue: "Keystore password error"
**Solution**: Verify password is correct, keystore path is valid

### Issue: "Ads not loading"
**Solution**:
1. Verify `USE_TEST_ADS` setting matches environment
2. Check AndroidManifest has correct App ID
3. Verify internet permission enabled
4. Check AdMob account status

### Issue: "App crashes on launch"
**Solution**:
1. Check `adb logcat` for errors
2. Verify all scenes load correctly
3. Test debug build first
4. Check for missing resources

### Issue: "Wrong screen orientation"
**Solution**: Verify AndroidManifest has `screenOrientation="portrait"`

---

## Build Outputs Explained

### APK (Android Package)
- **Size**: Larger (includes all architectures)
- **Use**: Direct installation, testing
- **Format**: `tutti-fruitini.apk`

### AAB (Android App Bundle)
- **Size**: Smaller (Play Store optimizes per device)
- **Use**: Play Store upload (recommended)
- **Format**: `tutti-fruitini.aab`
- **Note**: Requires Play Store to install (can't sideload)

**Recommendation**: Use AAB for Play Store, APK for testing

---

## Final Pre-Publish Checklist

**Before Uploading to Play Store**:

- [ ] Release build tested on real device
- [ ] Production ads working correctly
- [ ] All critical features working
- [ ] No crashes or major bugs
- [ ] App icon looks good
- [ ] Version code/name correct
- [ ] Privacy policy created (see below)
- [ ] Store listing prepared (screenshots, description)
- [ ] AdMob account approved
- [ ] Google Play Console account setup

---

## Privacy Policy Requirement

**Google Play REQUIRES a privacy policy for apps with ads**.

**Minimum Content**:
```
Privacy Policy for Tutti Fruttini

This app uses Google AdMob to display advertisements.

Data Collected by AdMob:
- Advertising ID
- Device information
- App usage data

This data is used solely for serving relevant advertisements.
We do not collect, store, or share any personal information directly.

To opt out of personalized ads:
Settings → Google → Ads → Opt out of Ads Personalization

For more information:
Google Privacy Policy: https://policies.google.com/privacy

Contact: [your email]
```

**Host Privacy Policy**:
- Create page at: `https://yourdomain.com/privacy.html`
- Or use GitHub Pages
- Add URL to Play Store listing

---

## Next Steps After Build

1. **Test on Multiple Devices**
   - Low-end (Android 7-9, 2GB RAM)
   - Mid-range (Android 10-12, 4GB RAM)
   - High-end (Android 13+, 8GB+ RAM)

2. **Monitor Performance**
   - FPS (should be 45+ on all devices)
   - Load time (should be <3s)
   - Memory usage (should be <200MB)
   - No crashes

3. **Prepare Play Store Listing**
   - Screenshots (5+ required)
   - Feature graphic (1024x500)
   - App description
   - Privacy policy URL

4. **Upload to Play Store**
   - Internal testing first
   - Alpha/Beta testing (optional)
   - Production release

---

## Quick Reference: Build Commands

**Debug Build** (Godot Editor):
```
Project → Export → Android → Export Project (with debug checked)
```

**Release Build** (Godot Editor):
```
Project → Export → Android → Export AAB (with debug unchecked)
```

**Install APK**:
```bash
adb install tutti-fruitini.apk
```

**View Logs**:
```bash
adb logcat | grep Godot
```

---

## Estimated Timeline

**If everything is ready**:
- Android setup: 1-2 hours
- First build: 30 minutes
- Testing: 1-2 hours
- Fixes and rebuild: 1-2 hours
- **Total**: 4-8 hours

**If assets/features missing**:
- Add above time + content creation time

---

## Current Status for Tutti Fruttini

**Ready** ✅:
- [x] Core game functional
- [x] AdMob integration coded
- [x] Settings/Pause menus
- [x] Save system
- [x] Performance optimized

**Needed** ⏳:
- [ ] Android build template installed
- [ ] Export preset configured
- [ ] AndroidManifest.xml edited
- [ ] AdMob plugin installed
- [ ] App icon created
- [ ] Release keystore created
- [ ] Test build on device
- [ ] Privacy policy created

**Optional but Recommended** 🎯:
- [ ] Fruit sprites (currently colored circles)
- [ ] Audio files (currently silent)
- [ ] Balance testing

---

## Support Resources

- **Godot Docs**: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- **AdMob Plugin**: https://github.com/Poing-Studios/godot-admob-plugin
- **Google Play Console**: https://play.google.com/console
- **AdMob Console**: https://admob.google.com

---

**Ready to start?** Begin with Step 1: Install Android Build Template!
