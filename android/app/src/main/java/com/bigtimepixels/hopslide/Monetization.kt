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
import com.google.android.gms.ads.*
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
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
                interstitial = null
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
        if (disposed || !allowedToRequest) { ready = false; interstitial = null; return }
        if (initialized) { ready = true; loadInterstitial(); return }
        if (initializing) return
        initializing = true
        Thread {
            MobileAds.initialize(activity.applicationContext) {
                handler.post { if (!disposed) { initialized = true; initializing = false; ready = allowedToRequest; if (ready) loadInterstitial() } }
            }
        }.start()
    }

    fun onResume() {
        if (ready && !showing) loadInterstitial()
    }

    private fun expireInterstitial() {
        if (interstitial != null && SystemClock.elapsedRealtime() - loadedAt >= 3_600_000L) interstitial = null
    }

    private fun loadInterstitial() {
        expireInterstitial()
        if (!ready || !allowedToRequest || disposed || loading || showing || interstitial != null) return
        loading = true
        val requestGeneration = consentGeneration
        InterstitialAd.load(activity, BuildConfig.INTERSTITIAL_AD_UNIT_ID, AdRequest.Builder().build(), object : InterstitialAdLoadCallback() {
            override fun onAdLoaded(ad: InterstitialAd) {
                loading = false
                if (!disposed && ready && allowedToRequest) {
                    if (requestGeneration == consentGeneration) { interstitial = ad; loadedAt = SystemClock.elapsedRealtime() }
                    else loadInterstitial()
                }
            }
            override fun onAdFailedToLoad(error: LoadAdError) {
                loading = false
                Log.w("BigTimePixelsAds", "Interstitial unavailable: ${error.message}")
                handler.postDelayed({ loadInterstitial() }, 60_000)
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
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            private fun finished() { showing = false; loadInterstitial() }
            override fun onAdDismissedFullScreenContent() = finished()
            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                Log.w("BigTimePixelsAds", "Interstitial skipped: ${error.message}")
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
            interstitial = null
            if (!allowedToRequest) { ready = false }
            else initializeIfAllowed()
        }
    }

    fun dispose() { disposed = true; ready = false; interstitial = null; handler.removeCallbacksAndMessages(null) }
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
    val context = LocalContext.current
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    var loaded by remember { mutableStateOf(false) }
    val handler = remember { Handler(Looper.getMainLooper()) }
    val adView = remember(context) { AdView(context).apply {
        adUnitId = BuildConfig.BANNER_AD_UNIT_ID
        setAdSize(AdSize.BANNER)
    } }
    var requesting by remember { mutableStateOf(false) }
    var requestGeneration by remember { mutableIntStateOf(0) }
    fun requestBanner() {
        if (ads.ready && !requesting && lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            requesting = true
            requestGeneration = ads.consentGeneration
            adView.loadAd(AdRequest.Builder().build())
        }
    }
    DisposableEffect(adView, lifecycle) {
        adView.adListener = object : AdListener() {
            override fun onAdLoaded() {
                requesting = false
                loaded = ads.ready && requestGeneration == ads.consentGeneration
                if (!loaded && ads.ready) requestBanner()
            }
            override fun onAdFailedToLoad(error: LoadAdError) {
                requesting = false
                Log.w("BigTimePixelsAds", "Banner unavailable: ${error.message}")
                handler.postDelayed({ requestBanner() }, 60_000)
            }
        }
        val observer = LifecycleEventObserver { _, event -> when (event) {
            Lifecycle.Event.ON_RESUME -> { adView.resume(); if (!loaded) requestBanner() }
            Lifecycle.Event.ON_PAUSE -> adView.pause()
            else -> Unit
        } }
        lifecycle.addObserver(observer)
        onDispose { lifecycle.removeObserver(observer); handler.removeCallbacksAndMessages(null); adView.adListener = object : AdListener() {}; adView.destroy() }
    }
    LaunchedEffect(ads.ready, ads.consentGeneration) {
        loaded = false
        if (ads.ready) { adView.resume(); requestBanner() } else adView.pause()
    }
    if (loaded) Box(modifier.fillMaxWidth().navigationBarsPadding().clipToBounds(), contentAlignment = androidx.compose.ui.Alignment.Center) {
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
