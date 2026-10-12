package com.bigtimepixels.hopslide

import android.content.Context
import androidx.compose.ui.platform.LocalView
import android.view.ViewTreeObserver
import android.util.Log
import android.os.Looper
import android.os.Handler
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner

fun shareText(context: Context, text: String) {
    context.startActivity(Intent.createChooser(Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"; putExtra(Intent.EXTRA_TEXT, text)
    }, "Share"))
}

class AppSettings(context: Context) {
    private val prefs = context.getSharedPreferences("settings", Context.MODE_PRIVATE)
    var musicEnabled: Boolean
        get() = prefs.getBoolean("music_enabled", true)
        set(value) { prefs.edit().putBoolean("music_enabled", value).apply() }
    fun best(key: String = "best"): Float = prefs.getFloat(key, 0f)
    fun saveBest(value: Float, key: String = "best") { if (value > best(key)) prefs.edit().putFloat(key, value).apply() }
}

@Composable fun OnAppBackground(onBackground: () -> Unit) {
    val owner = LocalLifecycleOwner.current
    val current by rememberUpdatedState(onBackground)
    DisposableEffect(owner) {
        val observer = LifecycleEventObserver { _, event -> if (event == Lifecycle.Event.ON_PAUSE) current() }
        owner.lifecycle.addObserver(observer)
        onDispose { owner.lifecycle.removeObserver(observer) }
    }
}

class GameAudio(
    context: Context,
    assetName: String = "background_music.mp3",
    private val onInterruption: () -> Unit = {},
    private val onFocusChanged: (Boolean) -> Unit = {}
) {
    private val manager = context.getSystemService(AudioManager::class.java)
    private val handler = Handler(Looper.getMainLooper())
    private var requested = false
    private var enabled = false
    private var foreground = false
    private var windowFocused = false
    private var focus = false
    private var focusLost = false
    private var reportedFocus = false
    private var released = false
    private var retries = 0
    private val retryFocus = Runnable { sync() }
    private val player: MediaPlayer? = MediaPlayer().let { candidate ->
        try {
            candidate.apply {
                setAudioAttributes(AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                context.assets.openFd(assetName).use { setDataSource(it.fileDescriptor, it.startOffset, it.length) }
                isLooping = true
                setVolume(1f, 1f)
                setOnErrorListener { _, what, extra ->
                    Log.e("GameAudio", "Playback failed for $assetName: $what/$extra")
                    true
                }
                prepare()
                Log.i("GameAudio", "Bundled music prepared: $assetName (${duration}ms)")
            }
        } catch (error: Exception) {
            candidate.release()
            Log.e("GameAudio", "Could not prepare bundled music $assetName", error)
            null
        }
    }
    private val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
        .setAudioAttributes(AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
        .setAcceptsDelayedFocusGain(true)
        .setWillPauseWhenDucked(true)
        .setOnAudioFocusChangeListener({ change ->
            if (released) return@setOnAudioFocusChangeListener
            Log.d("GameAudio", "Audio focus changed: $change; foreground=$foreground windowFocused=$windowFocused")
            focus = change == AudioManager.AUDIOFOCUS_GAIN
            if (focus) focusLost = false
            if (focus && shouldPlay()) startPlayback() else pausePlayback()
            reportFocus(focus && shouldPlay())
            if (change == AudioManager.AUDIOFOCUS_LOSS) { requested = false; focusLost = true }
            if (change == AudioManager.AUDIOFOCUS_LOSS || change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT ||
                change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK) onInterruption()
        }, handler).build()
    fun setEnabled(value: Boolean) { if (enabled != value) { retries = 0; if (value) focusLost = false }; enabled = value; sync() }
    fun setForeground(value: Boolean) { if (foreground != value) { retries = 0; if (value) focusLost = false }; foreground = value; sync() }
    fun setWindowFocused(value: Boolean) { if (windowFocused != value) { retries = 0; if (value) focusLost = false }; windowFocused = value; sync() }
    private fun shouldPlay() = enabled && foreground && windowFocused && !focusLost && !released
    private fun reportFocus(value: Boolean) {
        if (reportedFocus != value) { reportedFocus = value; onFocusChanged(value) }
    }
    private fun startPlayback() {
        runCatching {
            val currentPlayer = player
            if (currentPlayer != null && !currentPlayer.isPlaying) {
                currentPlayer.start()
                Log.i("GameAudio", "Music playing; media volume=${manager.getStreamVolume(AudioManager.STREAM_MUSIC)}/${manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)} muted=${manager.isStreamMute(AudioManager.STREAM_MUSIC)}")
            }
        }
            .onFailure { Log.e("GameAudio", "Could not start bundled music", it) }
    }
    private fun pausePlayback() {
        runCatching { if (player?.isPlaying == true) player?.pause() }
            .onFailure { Log.e("GameAudio", "Could not pause bundled music", it) }
    }
    private fun sync() {
        handler.removeCallbacks(retryFocus)
        if (released) return
        if (shouldPlay() && player != null) {
            if (!requested) {
                val result = manager.requestAudioFocus(request)
                Log.d("GameAudio", "Audio focus request result=$result; foreground=$foreground windowFocused=$windowFocused attempt=${retries + 1}")
                requested = result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED || result == AudioManager.AUDIOFOCUS_REQUEST_DELAYED
                focus = result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
                if (result == AudioManager.AUDIOFOCUS_REQUEST_FAILED && retries++ < 8) {
                    // Android 15+ can deny a request made before the resumed window is topmost.
                    handler.postDelayed(retryFocus, 250)
                } else if (result == AudioManager.AUDIOFOCUS_REQUEST_FAILED) {
                    Log.w("GameAudio", "Audio focus remained unavailable after foreground retries; waiting for the next window/lifecycle change")
                }
            }
            if (focus) startPlayback() else pausePlayback()
            reportFocus(focus)
        } else {
            pausePlayback()
            if (requested) manager.abandonAudioFocusRequest(request)
            requested = false; focus = false; reportFocus(false)
        }
    }
    fun restart() {
        if (released) return
        runCatching { player?.seekTo(0) }.onFailure { Log.e("GameAudio", "Could not restart bundled music", it) }
        sync()
    }
    fun release() {
        if (released) return
        setForeground(false)
        released = true
        handler.removeCallbacks(retryFocus)
        manager.abandonAudioFocusRequest(request)
        player?.release()
    }
}

@Composable fun RememberGameAudio(enabled: Boolean, assetName: String = "background_music.mp3", onInterruption: () -> Unit = {}, onFocusChanged: (Boolean) -> Unit = {}): GameAudio {
    val context = LocalContext.current
    val view = LocalView.current
    val currentInterruption by rememberUpdatedState(onInterruption)
    val currentFocusChanged by rememberUpdatedState(onFocusChanged)
    val audio = remember(assetName) { GameAudio(context.applicationContext, assetName, { currentInterruption() }, { currentFocusChanged(it) }) }
    val owner = LocalLifecycleOwner.current
    SideEffect { audio.setEnabled(enabled) }
    DisposableEffect(owner, audio, view) {
        audio.setForeground(owner.lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED))
        audio.setWindowFocused(view.hasWindowFocus())
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) audio.setForeground(true)
            if (event == Lifecycle.Event.ON_PAUSE) audio.setForeground(false)
        }
        val focusListener = ViewTreeObserver.OnWindowFocusChangeListener { audio.setWindowFocused(it) }
        owner.lifecycle.addObserver(observer)
        view.viewTreeObserver.addOnWindowFocusChangeListener(focusListener)
        onDispose {
            owner.lifecycle.removeObserver(observer)
            if (view.viewTreeObserver.isAlive) view.viewTreeObserver.removeOnWindowFocusChangeListener(focusListener)
            audio.release()
        }
    }
    return audio
}

fun haptic(context: Context, millis: Long = 20L) {
    val vibrator = context.getSystemService(Vibrator::class.java)
    if (vibrator?.hasVibrator() == true) vibrator.vibrate(VibrationEffect.createOneShot(millis, VibrationEffect.DEFAULT_AMPLITUDE))
}
