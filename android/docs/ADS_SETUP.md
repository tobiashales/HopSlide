# HopSlide — Android ads setup

HopSlide uses Google Mobile Ads banners/interstitials and Google UMP consent handling.

## Configured identifiers

The supplied Android identifiers are already written to this project's local `ads.properties`. These files are excluded by each project's `.gitignore`; no further identifiers are needed. Generated release manifests and BuildConfig files have been checked against the supplied values.

| App | AdMob app ID | Banner unit | Interstitial unit |
| --- | --- | --- | --- |
| [HopSlide](../README.md) | `ca-app-pub-2060667001343293~8258855199` | `ca-app-pub-2060667001343293/3843958300` | `ca-app-pub-2060667001343293/3749509405` |

Configuration keys are documented in [ads.properties.example](../ads.properties.example). Keep the local `ads.properties` with the project when moving it to another machine.

Debug builds always use Google's sample app ID and test ad units, even when production identifiers are configured. Release builds use the supplied identifiers, disable the test fallback, and reject missing identifiers or Google's sample app ID. Release signing and store publication remain deferred; release configuration validation does not install an app or request live ads.

## Placements and timing

The original persistent bottom banner is retained at 50 dp above Android navigation, across main/menu, gameplay, results and credits as applicable. No empty banner area is retained when no ad is available.

HopSlide attempts an already-loaded interstitial only when the results screen's **Menu** artwork is tapped, matching their iOS source. **Retry**, gameplay Back, credits and ordinary menu navigation do not trigger one. Unavailable ads never delay navigation or produce a popup after the transition.


## AdMob account and privacy setup

In the AdMob account, verify that each supplied app ID belongs to the intended Android app/package and configure and publish the applicable messages under **Privacy & messaging**. UMP requests updated consent information at app launch and presents any required consent form. A **Privacy choices** action appears on credits when UMP requires an entry point, allowing users to revisit their choices. Google's [UMP setup guide](https://developers.google.com/admob/android/privacy) documents this account setup and request gating.

Production ad requests require UMP permission. The sample-app consent fallback is restricted to debug test inventory. Consent changes invalidate cached ads; failed loads remain nonblocking, banner loading recovers on foreground return, and interstitials expire after an hour. Live ad availability and region-specific consent forms depend on the published AdMob account configuration and have not been validated through live-ad requests.

From an app directory, validate the release identifiers without assembling or installing a release:

```sh
./gradlew processReleaseMainManifest generateReleaseBuildConfig --max-workers=2
```

Continue runtime testing with debug builds and [Google's test inventory](https://developers.google.com/admob/android/test-ads).
