# Google Play Android fixes — November 12, 2026

The Desktop screenshots identify four recommendations for release 1.1.1 (3).

- Replace the transitive Fragment 1.1.0 with an explicit Fragment 1.8.9 dependency.
- Keep AndroidX `enableEdgeToEdge()` and apply safe-drawing insets to app content, including display cutouts and system navigation. Backgrounds still fill the window; the banner consumes only remaining insets.
- Migrate legacy Google Mobile Ads 25.5.0 to GMA Next-Gen 1.6.0, including its HSDP 2.2.0 dependency. Exclude the legacy ad runtime. Initialize off the main thread before constructing/loading ads; dispatch callbacks to the main thread; discard stale consent requests and release expired ads. Preserve production consent requirements, test-only fallback, existing ad placement and interstitial triggers.
- Enable release R8 optimization, obfuscation, and resource shrinking with the optimized Android defaults and SDK consumer rules. Keep source locations for retracing, without blanket keep rules.

Android version: **1.1.2 (4)**. iOS source is outside this change.

## Remaining Google SDK limitation

The legacy `com.google.android.gms.ads.internal.overlay.zzm` implementation is removed by the SDK migration. However, bytecode inspection confirms Google's **HSDP 2.2.0** still assigns `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES` in `HsdpShimActivity.onCreate`. Play may continue reporting that dependency-owned deprecation. Do not patch Google's binary, remove its activity, or suppress missing classes: those changes could break ads. Recheck Play's report after uploading the new production bundle and update HSDP when Google supplies a fix.

## Build and release

Use the project's normal Gradle wrapper and local `key.properties` / `ads.properties` for production. The existing release checks still reject missing upload signing or production ad IDs. Never upload a verification artifact using test inventory or debug signing.

R8 writes `app/build.nosync/outputs/mapping/release/mapping.txt`; archive the production mapping for each release. A new signed production AAB must be uploaded before Play can reassess the screenshots' old release.

## References

- [Google SDK migration](https://developers.google.com/admob/android/next-gen/migration)
- [Next-Gen release notes](https://developers.google.com/admob/android/next-gen/rel-notes)
- [Fragment releases](https://developer.android.com/jetpack/androidx/releases/fragment)

## Local verification

- Debug APK, 10 JVM unit tests, and debug lint passed.
- R8/resource-shrunk release APK and AAB built successfully. Mapping output confirms app classes are renamed.
- Release verification used a temporary external Gradle init script with debug signing and Google test ad IDs. No production signing or consent guard was changed. These verification artifacts are not suitable for Google Play upload.

Optimized APK startup was checked on an Android 16 (API 36) small-phone emulator. The emulator had a System UI ANR during concurrent builds; this was a system-process dialog, not an app crash. App-specific AndroidRuntime logs showed no startup exception. Full production ad delivery and Play warning clearance still require verification with the signed production release.
