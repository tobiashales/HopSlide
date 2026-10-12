# Hop Slide

The iOS and native Android versions share this repository. Each platform includes its own source, artwork, dependencies and build configuration.

- `ios/`: SpriteKit iPhone/iPad app, Xcode workspace and project, CocoaPods lockfile, and existing tvOS target.
- `android/`: Kotlin Android Studio project, Gradle wrapper, launcher icons, tests and platform documentation.

## iOS

Install Xcode and CocoaPods, then run:

```sh
cd ios
pod install
open HopSlide.xcworkspace
```

Use the `HopSlide` scheme for iOS. Configure your Apple development team and signing locally before installing on a physical device or archiving.

## Android

Open `android/` in Android Studio, or use JDK 17 and Android SDK 36:

```sh
cd android
./gradlew assembleDebug testDebugUnitTest lintDebug
```

The debug APK is generated at `android/app/build.nosync/outputs/apk/debug/app-debug.apk` relative to the repository root. See the [Android README](android/README.md) for gameplay, validation and ads setup.

## Local configuration

Android debug builds use test ads. For release builds, copy `android/ads.properties.example` to `android/ads.properties` and supply this Android app's production AdMob identifiers. Android Studio creates the local SDK path in `android/local.properties`.

Build output, downloaded dependencies, IDE user state, local configuration and signing/auth keys stay outside Git. Existing local APKs and bundles in `android/apk/` are optional delivery artifacts and are not part of a source checkout. Keep upload keystores and Apple notification keys backed up separately; a fresh checkout requires your own signing setup for distribution.
