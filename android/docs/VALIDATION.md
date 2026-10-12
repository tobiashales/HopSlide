# HopSlide — delivery validation

Validated 12 October 2026, version **1.1.0 (code 2)**. Cleanup preserves the app source, tests, assets, configuration and shipped APK byte-for-byte. Temporary logs, repeated screenshots, old build outputs and caches have been removed.

## Build results

`assembleDebug`, `testDebugUnitTest` and `lintDebug` passed with **10 JVM tests, zero failures, zero lint errors and 17 lint warnings**. Warnings include dependency-update suggestions and style/resource/orientation notices; requested versions remain pinned.

Ten JVM tests cover jumping/landing, visible collision edges, rounded artwork corners, single scoring, blue/red obstacles, progression and equivalent simulation at 60/90/120 Hz, and continuous ground scrolling.

## Device and visual checks

Pixel and Small Phone checks covered Rate, menu alignment, jumping, natural collision/results, Retry, Back to Menu, automatic Home/return continuation, music preference persistence, test banners and results → Menu interstitials. Offline play and banner recovery after background network restoration passed.

The original iOS app was opened for visual comparison. Android validation used Pixel 9 Pro XL and Small Phone emulators on Android 16/API 36, plus a 1600×2560, 240 dpi tablet-sized display override. Temporary display/network settings were restored. No crash or ANR involving this app was observed in the final checks.

## Included APK

[Installable debug APK](../apk/HopSlide-debug.apk), 20,539,938 bytes. [SHA-256 checksum](../apk/SHA256SUMS.txt):

```text
62ff74153c843ecb44f74977ccf2434b2f03039d60d9298391c43a773c275471
```

The APK is signed for local installation. Physical hardware, measured FPS, release signing and store publication remain untested/deferred. Production AdMob IDs are configured; debug builds use Google test inventory. Live serving and region-specific consent forms require account setup and were not exercised. See [ads setup](ADS_SETUP.md).

Source tests remain under `app/src/test`. Re-run the commands in [README](../README.md) to regenerate build/test/lint reports.
