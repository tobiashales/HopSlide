# Hop Slide for Android

Native Android conversion of the original Big Time Pixels iOS arcade game. This standalone Kotlin/Jetpack Compose Android Studio project uses a native Canvas/SurfaceView renderer and a fixed 120 Hz simulation. The original iOS project is unchanged.

## Play

Tap to jump over blue obstacles. Red obstacles jump toward you, so stay on the ground to slide under them. You can jump again after landing. Each obstacle you pass earns one point, and speed gradually increases. Retry starts a fresh run; your best score and music preference persist between launches.

The menu, game, results, and credits reuse the original art and looping music. Play suspends automatically while the app is in the background and continues when it returns. There is no pause overlay or Resume button. Android Back during a run returns to the menu. Sharing uses Android’s share sheet, and Rate opens this app’s Google Play listing, with a browser fallback when the Play Store is unavailable. Credits sits between Music and Share on the menu.

The game fills the screen beneath the transparent gesture bar. A persistent bottom banner overlays all screens, as in the original. The results screen’s Menu button requests an interstitial only when one is already ready; Retry, Back, credits, and initial launch do not show an interstitial. Consent and privacy options use Google’s User Messaging Platform.

## Build and verify

Open this directory in Android Studio, or use JDK 17 and Android SDK 36:

```sh
./gradlew --max-workers=2 assembleDebug testDebugUnitTest lintDebug
```

The debug APK is `app/build.nosync/outputs/apk/debug/app-debug.apk`. Android 8.0 (API 26) or newer is supported. `local.properties` is machine-specific; update `sdk.dir` for another development computer.

Generated outputs and caches are recreated when you build. This project keeps build output under `build.nosync`. Existing local delivery APKs and checksums may be kept in the ignored `apk/` folder; build the APK above on a fresh checkout. [Validation notes](docs/VALIDATION.md) summarize the delivered version.

The ten pure JVM tests cover jumping and landing, visible collision edges and transparent rounded corners, blue/red obstacle strategies, single scoring, exact equivalent simulation at 60, 90, and 120 caller updates per second, continuous ground movement, and bounded difficulty through a ten-minute run. Both model and renderer use fixed 120 Hz updates.


## Rendering and platform choices

- Best scores save as soon as points are earned. Difficulty and spawn intervals remain bounded, and every obstacle tracks its own scoring state.
- The original iOS “No Ads” button actually shared an App Store link. It is labeled Share here and uses Android’s share sheet.
- Ground scrolling retains continuous distance and repeats at the artwork’s scaled width. The earlier screen-width reset caused a visible jump because screen width and texture width differ. A single [BitmapShader](https://developer.android.com/reference/android/graphics/BitmapShader) with [REPEAT](https://developer.android.com/reference/android/graphics/Shader.TileMode#REPEAT) avoids separately drawn tile boundaries; [bitmap filtering](https://developer.android.com/reference/android/graphics/Paint#setFilterBitmap(boolean)) smooths the scaled artwork.
- Collision geometry follows the visible circular player and the obstacle artwork’s rounded outline, excluding transparent corners. Sprite scaling remains uniform across phone and tablet aspect ratios.
- Android audio waits for the resumed, focused app window before requesting focus, retries early focus denial, and automatically recovers after foreground/window changes. Music pauses on audio-focus loss. Preparation, playback errors, focus results, and media volume are logged under `GameAudio` for device diagnostics.
- Firebase notifications, Game Center, and billing remain excluded. Debug builds use Google’s published test ad inventory. The supplied production AdMob IDs are configured in the local `ads.properties`; release builds validate these values. For another checkout or app account, use `ads.properties.example` as the template. Publishing also requires a real Google Play listing, production consent configuration, and signing.
- The source includes the original artwork and music; distribution remains subject to their existing rights.

`tools/convert_assets.swift` converts the original PDF artwork to transparent PNGs using macOS CoreGraphics. Converted assets are included, so conversion tooling is unnecessary to build Android.

```sh
swift tools/convert_assets.swift ../ios/HopSlide/Assets.xcassets app/src/main/assets/art
```

## Project contents

- `app/src/`: application code, original assets, launcher icons and tests.
- `gradle/`, `gradlew`, `gradlew.bat` and Gradle configuration: independent Android Studio build.
- `apk/`: optional local delivery APKs and checksums, excluded from Git.
- `docs/`: local validation and AdMob setup notes.
- `ads.properties`: supplied production AdMob IDs; keep this ignored local file with the project.

This folder builds independently of neighboring projects and the iOS source folders. Use JDK 17 and Android SDK 36; the first Gradle sync downloads dependencies. Android Studio can regenerate the ignored `local.properties` SDK path on another machine. Gradle 8.13, Android Gradle Plugin 8.13.2, Kotlin/Compose compiler 2.3.10 and Compose BOM 2025.10.01 are pinned.

Install the generated debug APK after building:

```sh
adb install -r app/build.nosync/outputs/apk/debug/app-debug.apk
```
AdMob account configuration and production behavior are documented in [ads setup](docs/ADS_SETUP.md).
