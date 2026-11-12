package com.bigtimepixels.hopslide

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.google.android.libraries.ads.mobile.sdk.MobileAds
import com.google.android.libraries.ads.mobile.sdk.initialization.InitializationConfig
import com.google.android.libraries.ads.mobile.sdk.common.*
import com.google.android.libraries.ads.mobile.sdk.banner.*
import com.google.android.libraries.ads.mobile.sdk.interstitial.InterstitialAd
import com.google.android.libraries.ads.mobile.sdk.interstitial.InterstitialAdEventCallback
import com.google.android.ump.*

/** One owner per Activity; unavailable ads never delay navigation or appear later unexpectedly. */
class AdsController(private val activity: Activity) {
    var ready by mutableStateOf(false); private set
    var privacyRequired by mutableStateOf(false); private set
    private val consent = UserMessagingPlatform.getConsentInformation(activity)
    private val handler = Handler(Looper.getMainLooper())
    private var initializing = false
    private var initialized = false
    private var testFallbackAllowed = false
    var consentGeneration by mutableIntStateOf(0); private set
    private val allowedToRequest get() = consent.canRequestAds() || (BuildConfig.ADS_TEST_MODE && testFallbackAllowed)
    private var disposed = false
    private var loading = false
    private var showing = false
    private var interstitial: InterstitialAd? = null
    private var loadedAt = 0L

    fun start() {
        consent.requestConsentInfoUpdate(activity, ConsentRequestParameters.Builder().build(), success@{
            if (disposed) return@success
            privacyRequired = consent.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
            UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) form@{ error ->
                if (disposed) return@form
                consentGeneration++
                clearInterstitial()
                error?.let { Log.w("BigTimePixelsAds", "Consent: ${it.message}") }
                initializeIfAllowed()
            }
            initializeIfAllowed()
        }, { error ->
            Log.w("BigTimePixelsAds", "Consent update: ${error.message}")
            // The sample AdMob app has no publisher-configured consent form. Only test
            // inventory may run without that configuration; production requires UMP approval.
            initializeIfAllowed(allowTestInventory = BuildConfig.ADS_TEST_MODE)
        })
        initializeIfAllowed()
    }

    private fun initializeIfAllowed(allowTestInventory: Boolean = false) {
        if (allowTestInventory && BuildConfig.ADS_TEST_MODE) testFallbackAllowed = true
        if (disposed || !allowedToRequest) { ready = false; clearInterstitial(); return }
        if (initialized) { ready = true; loadInterstitial(); return }
        if (initializing) return
        initializing = true
        Thread {
            try {
                MobileAds.initialize(activity.applicationContext, InitializationConfig.Builder(BuildConfig.ADMOB_APP_ID).build())
                handler.post { if (!disposed) { initialized = true; initializing = false; ready = allowedToRequest; if (ready) loadInterstitial() } }
            } catch (error: Exception) {
                handler.post {
                    initializing = false
                    Log.w("BigTimePixelsAds", "Initialization unavailable", error)
                    if (!disposed) handler.postDelayed({ initializeIfAllowed() }, 60_000)
                }
            }
        }.start()
    }

    fun onResume() {
        if (ready && !showing) loadInterstitial()
    }

    private fun clearInterstitial() {
        interstitial?.destroy()
        interstitial = null
    }

    private fun expireInterstitial() {
        if (interstitial != null && SystemClock.elapsedRealtime() - loadedAt >= 3_600_000L) clearInterstitial()
    }

    private fun loadInterstitial() {
        expireInterstitial()
        if (!ready || !allowedToRequest || disposed || loading || showing || interstitial != null) return
        loading = true
        val requestGeneration = consentGeneration
        InterstitialAd.load(AdRequest.Builder(BuildConfig.INTERSTITIAL_AD_UNIT_ID).build(), object : AdLoadCallback<InterstitialAd> {
            override fun onAdLoaded(ad: InterstitialAd) {
                handler.post {
                    loading = false
                    if (!disposed && ready && allowedToRequest) {
                        if (requestGeneration == consentGeneration) { interstitial = ad; loadedAt = SystemClock.elapsedRealtime() }
                        else { ad.destroy(); loadInterstitial() }
                    } else ad.destroy()
                }
            }
            override fun onAdFailedToLoad(adError: LoadAdError) {
                handler.post {
                    if (disposed) return@post
                    loading = false
                    Log.w("BigTimePixelsAds", "Interstitial unavailable: ${adError.message}")
                    handler.postDelayed({ loadInterstitial() }, 60_000)
                }
            }
        })
    }

    /** Call only at an intentional content transition, never from a delayed timer. */
    fun showInterstitial(): Boolean {
        if (!ready || !allowedToRequest) return false
        expireInterstitial()
        val ad = interstitial ?: run { loadInterstitial(); return false }
        if (disposed || showing || activity.isFinishing || activity.isDestroyed ||
            (activity is androidx.lifecycle.LifecycleOwner && !activity.lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED))) return false
        interstitial = null
        showing = true
        ad.adEventCallback = object : InterstitialAdEventCallback {
            private fun finished() { handler.post { showing = false; if (!disposed) loadInterstitial() } }
            override fun onAdDismissedFullScreenContent() = finished()
            override fun onAdFailedToShowFullScreenContent(fullScreenContentError: FullScreenContentError) {
                Log.w("BigTimePixelsAds", "Interstitial skipped: ${fullScreenContentError.message}")
                finished()
            }
        }
        ad.show(activity)
        return true
    }

    fun showPrivacyOptions() {
        if (privacyRequired && !disposed) UserMessagingPlatform.showPrivacyOptionsForm(activity) privacy@{ error ->
            if (disposed) return@privacy
            error?.let { Log.w("BigTimePixelsAds", "Privacy options: ${it.message}") }
            privacyRequired = consent.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
            consentGeneration++
            clearInterstitial()
            if (!allowedToRequest) { ready = false }
            else initializeIfAllowed()
        }
    }

    fun dispose() { disposed = true; ready = false; clearInterstitial(); handler.removeCallbacksAndMessages(null) }
}

private tailrec fun Context.activity(): Activity = when (this) {
    is Activity -> this
    is ContextWrapper -> baseContext.activity()
    else -> error("Ads require an Activity context")
}

@Composable fun rememberAdsController(): AdsController {
    val activity = LocalContext.current.activity()
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    val controller = remember(activity) { AdsController(activity) }
    DisposableEffect(controller, lifecycle) {
        controller.start()
        val observer = LifecycleEventObserver { _, event -> if (event == Lifecycle.Event.ON_RESUME) controller.onResume() }
        lifecycle.addObserver(observer)
        onDispose { lifecycle.removeObserver(observer); controller.dispose() }
    }
    return controller
}

/** Original iOS placement: persistent 50-point overlay above the home safe area.
 * No white placeholder is retained offline or after an unsuccessful request. */
@Composable fun AdBanner(ads: AdsController, modifier: Modifier = Modifier) {
    // Next-Gen requires initialization before AdView construction. Recreate the view
    // when consent changes so a stale request can never become visible afterwards.
    if (ads.ready) key(ads.consentGeneration) { ReadyAdBanner(modifier) }
}

@Composable private fun ReadyAdBanner(modifier: Modifier) {
    val context = LocalContext.current
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    val handler = remember { Handler(Looper.getMainLooper()) }
    val adView = remember(context) { AdView(context) }
    var loaded by remember { mutableStateOf(false) }
    var requesting by remember { mutableStateOf(false) }
    var disposed by remember { mutableStateOf(false) }
    fun requestBanner() {
        if (disposed || requesting || loaded || !lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) return
        requesting = true
        adView.loadAd(BannerAdRequest.Builder(BuildConfig.BANNER_AD_UNIT_ID, AdSize.BANNER).build(),
            object : AdLoadCallback<BannerAd> {
                override fun onAdLoaded(ad: BannerAd) {
                    handler.post {
                        if (!disposed) { requesting = false; loaded = true }
                    }
                }
                override fun onAdFailedToLoad(adError: LoadAdError) {
                    handler.post {
                        if (!disposed) {
                            requesting = false
                            Log.w("BigTimePixelsAds", "Banner unavailable: ${adError.message}")
                            handler.postDelayed({ requestBanner() }, 60_000)
                        }
                    }
                }
            })
    }
    DisposableEffect(adView, lifecycle) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) requestBanner()
        }
        lifecycle.addObserver(observer)
        requestBanner()
        onDispose {
            disposed = true
            lifecycle.removeObserver(observer)
            handler.removeCallbacksAndMessages(null)
            adView.destroy()
        }
    }
    if (loaded) Box(modifier.fillMaxWidth().windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Horizontal + WindowInsetsSides.Bottom)).clipToBounds(), contentAlignment = androidx.compose.ui.Alignment.Center) {
        Box(Modifier.fillMaxWidth().height(50.dp).background(Color.White), contentAlignment = androidx.compose.ui.Alignment.Center) {
            AndroidView(factory = { adView }, modifier = Modifier.size(320.dp, 50.dp))
        }
    }
}

@Composable fun AdPrivacyOptions(ads: AdsController, modifier: Modifier = Modifier) {
    if (ads.privacyRequired) TextButton(onClick = ads::showPrivacyOptions, modifier = modifier.navigationBarsPadding().padding(bottom = 54.dp)) {
        Text("Privacy choices")
    }
}
